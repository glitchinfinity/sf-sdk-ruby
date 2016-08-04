require 'spec_helper'
require 'uri'

describe SFRest::Task do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
    define_task_statuses
    # @running_statuses = [SFRest::Task::STATUS_WAITING,
    #                      SFRest::Task::STATUS_IN_PROCESS]
    # @not_started_statuses = [SFRest::Task::STATUS_NOT_STARTED,
    #                          SFRest::Task::STATUS_RESTARTED,
    #                          SFRest::Task::STATUS_TO_BE_RUN]
    # @finished_statuses = [SFRest::Task::STATUS_COMPLETED,
    #                       SFRest::Task::STATUS_ERROR,
    #                       SFRest::Task::STATUS_KILLED,
    #                       SFRest::Task::STATUS_WARNING,
    #                       SFRest::Task::STATUS_DONE]
    # @not_finished_statuses = @not_started_statuses + @running_statuses
    # @completedish_statuses = [SFRest::Task::STATUS_COMPLETED,
    #                           SFRest::Task::STATUS_WARNING,
    #                           SFRest::Task::STATUS_DONE]
    # @all_statuses = @not_finished_statuses + @finished_statuses
  end

  describe '#status_completed?' do
    it 'returns true of it gets a completed value' do
      expect(@conn.task.status_completed?(SFRest::Task::STATUS_COMPLETED)).to be true
    end
    it 'returns false of it gets some other value' do
      @not_finished_statuses.each do |status|
        expect(@conn.task.status_completed?(status)).to be false
      end
    end
  end

  describe '#status_running?' do
    it 'returns true of it gets a running value' do
      @running_statuses.each do |status|
        expect(@conn.task.status_running?(status)).to be true
      end
    end
    it 'returns false of it gets some other value' do
      (@not_started_statuses + @finished_statuses).each do |status|
        expect(@conn.task.status_running?(status)).to be false
      end
    end
  end

  describe '#status_error?' do
    it 'returns true of it gets a error value' do
      expect(@conn.task.status_error?(SFRest::Task::STATUS_ERROR)).to be true
    end
    it 'returns false of it gets some other value' do
      (@all_statuses - [SFRest::Task::STATUS_ERROR]).each do |status|
        expect(@conn.task.status_error?(status)).to be false
      end
    end
  end

  describe '#status_killed?' do
    it 'returns true of it gets a killed value' do
      expect(@conn.task.status_killed?(SFRest::Task::STATUS_KILLED)).to be true
    end
    it 'returns false of it gets some other value' do
      (@all_statuses - [SFRest::Task::STATUS_KILLED]).each do |status|
        expect(@conn.task.status_killed?(status)).to be false
      end
    end
  end

  describe '#status_done?' do
    it 'returns true of it gets a done value' do
      @finished_statuses.each do |status|
        expect(@conn.task.status_done?(status)).to be true
      end
    end
    it 'returns false of it gets a not done value' do
      @not_finished_statuses.each do |status|
        expect(@conn.task.status_done?(status)).to be false
      end
    end
  end

  describe '#task_running?' do
    it 'can detect a running task' do
      status_response = generate_task_status @running_statuses.sample
      tid = status_response['wip_task']['id']
      stub_factory %r{/api/v1/wip/task/\d+/status}, status_response.to_json
      expect(@conn.task.task_running?(tid)).to be true
    end
  end

  describe '#task_completed?' do
    it 'can detect a completed  task' do
      status_response = generate_task_status SFRest::Task::STATUS_COMPLETED
      tid = status_response['wip_task']['id']
      stub_factory %r{/api/v1/wip/task/\d+/status}, status_response.to_json
      expect(@conn.task.task_completed?(tid)).to be true
    end
  end

  describe '#task_done?' do
    it 'can detect a finished task' do
      status_response = generate_task_status @finished_statuses.sample
      tid = status_response['wip_task']['id']
      stub_factory %r{/api/v1/wip/task/\d+/status}, status_response.to_json
      expect(@conn.task.task_done?(tid)).to be true
    end
  end

  describe '#task_killed?' do
    it 'can detect a killed task' do
      status_response = generate_task_status SFRest::Task::STATUS_KILLED
      tid = status_response['wip_task']['id']
      stub_factory %r{/api/v1/wip/task/\d+/status}, status_response.to_json
      expect(@conn.task.task_killed?(tid)).to be true
    end
  end

  describe '#task_errored?' do
    it 'can detect a errored task' do
      status_response = generate_task_status SFRest::Task::STATUS_ERROR
      tid = status_response['wip_task']['id']
      stub_factory %r{/api/v1/wip/task/\d+/status}, status_response.to_json
      expect(@conn.task.task_errored?(tid)).to be true
    end
  end

  describe '#find_tasks' do
    it 'can take no argument' do
      path = '/api/v1/tasks'
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri }.to_json } }
      res = @conn.task.find_tasks
      uri = URI res['uri']
      expect(uri.path).to eq path
    end

    it 'can build a url' do
      path = '/api/v1/tasks'
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri }.to_json } }
      res = @conn.task.find_tasks(class: 'foobar')
      uri = URI res['uri']
      query_hash = URI.decode_www_form(uri.query).to_h
      expect(uri.path).to eq path
      expect(query_hash['class']).to eq 'foobar'
    end

    it 'can build a url with multiple parameters' do
      path = '/api/v1/tasks'
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri }.to_json } }
      res = @conn.task.find_tasks(class: 'foobar', limit: 10, group: 'batpig')
      uri = URI res['uri']
      query_hash = URI.decode_www_form(uri.query).to_h
      expect(uri.path).to eq path
      expect(query_hash['class']).to eq 'foobar'
      expect(query_hash['group']).to eq 'batpig'
      expect(query_hash['limit']).to eq '10'
    end
  end

  describe '#find_task_ids' do
    tasks = generate_tasks
    it 'can get a set of task ids' do
      stub_factory '/api/v1/tasks', tasks.to_json
      res = @conn.task.find_task_ids
      expect(res).to be_a Array
      res.each { |item| expect(item).to be_a Integer }
    end
  end

  describe '#get_task_id' do
    it 'can get task id for a named task' do
      tasks = generate_tasks
      task = tasks.sample
      task_id = task['id']
      task_name = task['name']
      stub_factory '/api/v1/tasks', tasks.to_json
      expect(@conn.task.get_task_id(task_name)).to eq task_id
    end

    it 'Wont loop infinitely' do
      tasks = generate_tasks 50
      fake_name = SecureRandom.urlsafe_base64
      stub_factory '/api/v1/tasks', tasks.to_json
      expect(@conn.task.get_task_id(fake_name)).to eq nil
    end
  end

  describe '#pause_all_tasks' do
    path = '/api/v1/pause'

    it 'calls the pause endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      res = @conn.task.pause_all_tasks
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['paused']).to eq true
    end
  end

  describe '#resume_all_tasks' do
    path = '/api/v1/pause'

    it 'calls the pause endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      res = @conn.task.resume_all_tasks
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['paused']).to eq false
    end
  end

  describe '#get_task_logs' do
    path = '/api/v1/tasks'

    it 'calls the task logs endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      tid = rand 10**5
      res = @conn.task.get_task_logs tid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{tid}/logs"
    end
  end

  describe '#globally_paused?' do
    it 'calls the globally_paused? endpoint' do
      variable = SecureRandom.urlsafe_base64
      var_value = SecureRandom.urlsafe_base64
      stub_factory '/api/v1/variables', { variable => var_value }.to_json
      res = @conn.task.globally_paused? variable
      expect(res).to eq var_value
    end
  end

  describe '#pause_task' do
    path = '/api/v1/pause'

    it 'pauses a task and children' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      tid = rand 10**5
      res = @conn.task.pause_task tid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{tid}"
      expect(JSON(res['body'])['paused']).to eq true
      expect(JSON(res['body'])['level']).to eq 'family'
    end

    it 'pauses a task only' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      tid = rand 10**5
      res = @conn.task.pause_task tid, 'task'
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{tid}"
      expect(JSON(res['body'])['paused']).to eq true
      expect(JSON(res['body'])['level']).to eq 'task'
    end
  end

  describe '#resume_task' do
    path = '/api/v1/pause'

    it 'calls the pause tasks endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      tid = rand 10**5
      res = @conn.task.resume_task tid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{tid}"
      expect(JSON(res['body'])['paused']).to eq false
      expect(JSON(res['body'])['level']).to eq 'family'
    end

    it 'resumes a specific task only' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      tid = rand 10**5
      res = @conn.task.resume_task tid, 'task'
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{tid}"
      expect(JSON(res['body'])['paused']).to eq false
      expect(JSON(res['body'])['level']).to eq 'task'
    end
  end

  describe '#get_task_class_info' do
    path = '/api/v1/classes'

    it 'calls the  classs info endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      class_type = SecureRandom.urlsafe_base64
      res = @conn.task.get_task_class_info class_type
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{class_type}"
    end
  end

  describe '#get_wip_task_status' do
    path = '/api/v1/wip'

    it 'calls the task status endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body }.to_json } }
      tid = rand 10**5
      res = @conn.task.get_wip_task_status tid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/task/#{tid}/status"
    end
  end

  describe '#wait_until_done' do
    it 'waits until a wip is done' do
      status_response = generate_task_status @finished_statuses.sample
      tid = status_response['wip_task']['id']
      stub_factory %r{/api/v1/wip/task/\d+/status}, status_response.to_json
      expect(@conn.task.wait_until_done(tid)).to be tid
    end

    it 'errors if a wip is not done' do
      status_response = generate_task_status @running_statuses.sample
      tid = status_response['wip_task']['id']
      stub_factory %r{/api/v1/wip/task/\d+/status}, status_response.to_json
      expect { @conn.task.wait_until_done(tid, 1) }.to raise_error(SFRest::TaskNotDoneError)
    end
  end
end
