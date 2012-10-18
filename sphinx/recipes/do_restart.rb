#
# Cookbook Name:: sphinx
#

rightscale_marker :begin

log "  Restarting sphinx"

service "searchd" do
  action :restart
end
 
rightscale_marker :end
