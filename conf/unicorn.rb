# config/unicorn.rb
deploy_to = '/home/NorthernHemisphere/ihakula-service/conf'
pid_file = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file= "#{deploy_to}/shared/unicorn.sock"
log_file = "#{deploy_to}/shared/log/unicorn.log"
err_log = "#{deploy_to}/shared/log/unicorn_error.log"
old_pid = pid_file + '.oldbin'

timeout 30
worker_processes 2 # increase or decrease
listen socket_file, :backlog => 512

pid pid_file
stderr_path err_log
stdout_path log_file
