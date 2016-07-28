module SFRest
  # Deal with tasks, find them, pause them...
  class Task
    STATUS_NOT_STARTED = 1 # Task has been added to queue but not picked up
    STATUS_RESTARTED   = 2 # Task has been re-added to the queue but not picked up
    STATUS_TO_BE_RUN   = 3 # Restarted + not started
    STATUS_IN_PROCESS  = 4 # A wip process is actively processing a task
    STATUS_WAITING     = 8 # Task has been released from active processing
    STATUS_RUNNING     = 12 # Running = in process + waiting to be processed
    STATUS_COMPLETED   = 16 # Task is successfully processed (exited with success)
    STATUS_ERROR       = 32 # Task unsccuessfully completed (exited with failure)
    STATUS_KILLED      = 64 # Task is terminated
    STATUS_WARNING     = 144 # Completed bit + 128 bit(warning).
    STATUS_DONE        = 240 # Completed + error + killed + 128 bit(warning)

    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Returns true only if the status evaluates to completed
    # @param [Integer] status
    # @return [Boolean]
    def status_completed?(status)
      return true if status.to_i == STATUS_COMPLETED
      false
    end

    # Returns true if the status evaluates to either
    # waiting or in process
    # @param [Integer] status
    # @return [Boolean]
    def status_running?(status)
      return true if (status.to_i & STATUS_RUNNING) > 0
      false
    end

    # Returns true only if the status evaluates to errored
    # @param [Integer] status
    # @return [Boolean]
    def status_error?(status)
      return true if status.to_i == STATUS_ERROR
      false
    end

    # Returns true only if the status evaluates to killed
    # @param [Integer] status
    # @return [Boolean]
    def status_killed?(status)
      return true if status.to_i == STATUS_KILLED
      false
    end

    # Returns true if the status evaluates to a state that is
    # considered done
    # @param [Integer] status
    # @return [Boolean]
    def status_done?(status)
      return true if (status.to_i & STATUS_DONE) > 0
      false
    end

    # Returns true only if WIP reports the status as running
    # @param [Integer] task_id
    # @return [Boolean]
    def task_running?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_running?(status)
    end

    # Returns true only if WIP reports the status as completed
    # @param [Integer] task_id
    # @return [Boolean]
    def task_completed?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_completed?(status)
    end

    # Returns true if WIP reports the status in a state that is
    # considered done
    # @param [Integer] task_id
    # @return [Boolean]
    def task_done?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_done?(status)
    end

    # Returns true only if WIP reports the status as killed
    # @param [Integer] task_id
    # @return [Boolean]
    def task_killed?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_killed?(status)
    end

    # Returns true only if WIP reports the status as errored
    # @param [Integer] task_id
    # @return [Boolean]
    def task_errored?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_error?(status)
    end

    # Find a set of task ids.
    # @param [Integer] limit max amount of results to return per request
    # @param [Integer] page page of request
    # @param [String] group task group
    # @param [String] klass task class
    # @param [Integer] status Integerish the status of the task
    #         see SFRest::Task::STATUS_*
    # @return [Array[Integer]]
    def find_task_ids(limit = nil, page = nil, group = nil, klass = nil, status = nil)
      res = find_tasks limit: limit, page: page, group: group, klass: klass, status: status
      task_ids = []
      i = 0
      res.each do |task|
        task_ids[i] = task['id']
        i += 1
      end
      task_ids
    end

    # Find a set of tasks.
    # @param [Hash] datum Hash of filters
    # @option datum [Integer] :limit max amount of results to return per request
    # @option datum [Integer] :page page of request
    # @option datum [String] :group task group
    # @option datum [String] :class task class
    # @option datum [Integer] :status Integerish the status of the task
    #         see SFRest::Task::STATUS_*
    def find_tasks(datum = nil)
      current_path = '/api/v1/tasks'
      pb = SFRest::Pathbuilder.new
      @conn.get URI.parse(URI.encode(pb.build_url_query(current_path, datum))).to_s
    end

    # Looks for a task with a specific name
    # @param [String] name display name of the task
    # @param [String] group task group filter
    # @param [String] klass task class filter
    # @param [String] status task status filter
    def get_task_id(name, group = nil, klass = nil, status = nil)
      page_size = 100
      page = 0
      loop do
        tasks = find_tasks(limit: page_size, page: page, group: group, class: klass, status: status)
        tasks.each do |task|
          return task['id'].to_i if task['name'] =~ /#{name}/
          page += 1
        end
        break if tasks.size < page_size
      end
      nil
    end

    # Pauses all tasks.
    def pause_all_tasks
      current_path = '/api/v1/pause'
      payload = { 'paused' => true }.to_json
      @conn.post(current_path, payload)
    end

    # Resumes all tasks.
    def resume_all_tasks
      current_path = '/api/v1/pause'
      payload = { 'paused' => false }.to_json
      @conn.post(current_path, payload)
    end

    # Get a specific task's logs
    # @param [Integer] task_id
    def get_task_logs(task_id)
      current_path = '/api/v1/tasks/' << task_id.to_s << '/logs'
      @conn.get(current_path)
    end

    # Gets the value of a vairable
    # @TODO: this is missnamed becasue it does not check the global paused variable
    # @param [String] variable_name
    # @return [Object]
    def globally_paused?(variable_name)
      current_path = "/api/v1/variables?name=#{variable_name}"
      res = @conn.get(current_path)
      res[variable_name]
    end

    # Pauses a specific task identified by its task id.
    # This can pause either the task and it's children or just the task
    # @param [Integer] task_id
    # @param [String] level family|task
    def pause_task(task_id, level = 'family')
      current_path = '/api/v1/pause/' << task_id.to_s
      payload = { 'paused' => true, 'level' => level }.to_json
      @conn.post(current_path, payload)
    end

    # Resumes a specific task identified by its task id.
    # This can resume either the task and it's children or just the task
    # @param [Integer] task_id
    # @param [String] level family|task
    def resume_task(task_id, level = 'family')
      current_path = '/api/v1/pause/' << task_id.to_s
      payload = { 'paused' => false, 'level' => level }.to_json
      @conn.post(current_path, payload)
    end

    # returns the classes that are either softpaused or softpause-for-update
    # @param [String] type softpaused | softpause-for-update
    # @return [Array] Array of wip classes
    def get_task_class_info(type = '')
      current_path = '/api/v1/classes/' << type
      @conn.get(current_path)
    end

    # Get the status of a wip task by id.
    # @param [Integer] task_id
    # @return [Hash{"wip_task" => {"id" => Integer, "status" => Integer}, "time" => timestamp}]
    def get_wip_task_status(task_id)
      current_path = "/api/v1/wip/task/#{task_id}/status"
      @conn.get(current_path)
    end

    # Blocks until a task is done
    # @param [Integer] task_id
    # @param [Integer] max_nap seconds to try before giving up
    def wait_until_done(task_id, max_nap = 600)
      wait_until_state(task_id, 'done', max_nap)
    end

    # Blocks until a task reaches a specific status
    # @param [Integer] task_id
    # @param [String] state state to reach
    # @param [Integer] max_nap seconds to try before giving up
    def wait_until_state(task_id, state, max_nap)
      blink_time = 5 # wake up and scan
      nap_start = Time.now
      state_method = method("task_#{state}?".to_sym)
      loop do
        break if state_method.call(task_id)
        raise "Task: #{task_id} has taken too long to complete!" if Time.new > (nap_start + max_nap)
        sleep blink_time
      end
    end
  end
end
