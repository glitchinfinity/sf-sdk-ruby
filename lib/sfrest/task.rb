module SFRest
  # Deal with tasks, find them, pause them...
  class Task
    STATUS_NOT_STARTED = 1
    STATUS_RESTARTED   = 2
    STATUS_TO_BE_RUN   = 3 # Restarted + not started
    STATUS_IN_PROCESS  = 4
    STATUS_WAITING     = 8
    STATUS_RUNNING     = 12 # Running = in process + waiting to be processed
    STATUS_COMPLETED   = 16
    STATUS_ERROR       = 32
    STATUS_KILLED      = 64
    STATUS_WARNING     = 144 # Completed bit + 128 bit(warning).
    STATUS_DONE        = 240 # Completed + error + killed + 128 bit(warning)

    def initialize(conn)
      @conn = conn
    end

    def status_completed?(status)
      return true if status.to_i == STATUS_COMPLETED
      false
    end

    def status_running?(status)
      return true if (status.to_i & STATUS_RUNNING) > 0
      false
    end

    def status_error?(status)
      return true if status.to_i == STATUS_ERROR
      false
    end

    def status_killed?(status)
      return true if status.to_i == STATUS_KILLED
      false
    end

    def status_done?(status)
      return true if (status.to_i & STATUS_DONE) > 0
      false
    end

    def task_running?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_running?(status)
    end

    def task_completed?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_completed?(status)
    end

    def task_done?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_done?(status)
    end

    def task_killed?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_killed?(status)
    end

    def task_errored?(task_id)
      task_path = "/api/v1/wip/task/#{task_id}/status"

      res = @conn.get task_path
      status = res['wip_task']['status']
      status_error?(status)
    end

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

    private def needs_new_parameter?(path)
      path[-1, 1] != '?' # if path has '?' then we need to create a new parameter
    end

    # Find a set of tasks.
    # datum is a hash of
    # :limit, Integer max amount of results to return per request
    # :page, Integer page of request
    # :group, String the task group to filter on
    # :class String the task class to filter on
    # :status Integerish the status of the class to filter on.
    #         see SFRest::Task::STATUS_*
    def find_tasks(datum = nil)
      current_path = '/api/v1/tasks'

      unless datum.nil?
        current_path << '?'
        datum.each do |key, value|
          current_path << '&' if needs_new_parameter? current_path
          current_path << key.to_s << '=' << value.to_s
        end
      end
      @conn.get URI.parse(URI.encode(current_path)).to_s
    end

    # Looks for a task
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
    def get_task_logs(task_id)
      current_path = '/api/v1/tasks/' << task_id.to_s << '/logs'
      @conn.get(current_path)
    end

    # Checks if a variable is globally paused.
    def globally_paused?(variable_name)
      current_path = "/api/v1/variables?name=#{variable_name}"
      res = @conn.get(current_path)
      res[variable_name]
    end

    # Pauses a specific task identified by its task id.
    # CURRENTLY NOT FUNCTIONING, ISSUES WITH REST TASK-PAUSING FUNCTIONALITY.
    def pause_task(task_id, level = 'family')
      current_path = '/api/v1/pause/' << task_id.to_s
      payload = { 'pause' => true, 'level' => level }.to_json
      @conn.post(current_path, payload)
    end

    # Pauses a specific task identified by its task id.
    # CURRENTLY NOT FUNCTIONING, ISSUES WITH REST TASK-PAUSING FUNCTIONALITY.
    def resume_task(task_id, level = 'family')
      current_path = '/api/v1/pause/' << task_id.to_s
      payload = { 'pause' => false, 'level' => level }.to_json
      @conn.post(current_path, payload)
    end

    def get_task_class_info(type = '')
      current_path = '/api/v1/classes/' << type
      @conn.get(current_path)
    end

    # Get the status of a wip task by id.
    def get_wip_task_status(task_id)
      current_path = "/api/v1/wip/task/#{task_id}/status"
      @conn.get(current_path)
    end
  end
end
