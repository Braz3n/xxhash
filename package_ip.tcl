# # Create a new project
# create_project -force xxhash32 ./xxhash32_project -part xc7z020clg400-1

# # Add the Verilog source file
# add_files ./src/xxhash32.sv

# # Set the top module
# set_property top xxhash32 [current_fileset]

# # Create a new IP package
# ipx::package_project -name xxhash32 -vendor Zane -library user -version 1.0 -root_dir ./xxhash32_ip

# # Add the Verilog source file to the IP package
# ipx::add_file_group -file_group "rtl" -type "verilog"
# ipx::add_file -file_group "rtl" ./src/xxhash32.sv

# # Add ports to the IP package
# ipx::add_port -name clk -dir in -type clk
# ipx::add_port -name add_to_hash -dir in -type data
# ipx::add_port -name request_hash -dir in -type data
# ipx::add_port -name seed_in -dir in -type data
# ipx::add_port -name input_bytes -dir in -type data -bus 32
# ipx::add_port -name hash_ready -dir out -type data
# ipx::add_port -name output_hash -dir out -type data -bus 32

# # Save and finalize the IP package
# ipx::save_core -core_name xxhash32
# ipx::done

# # Close the project
# close_project



### Copied from Vivado
create_project -force xxhash32 ./xxhash32_ip_project -part xc7a100tcsg324-1
add_files ./src/xxhash32.sv

ipx::package_project -force -root_dir /home/zane/ip_repo -vendor user.org -library user -taxonomy /UserIP
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  ./ip_repo [current_project]
update_ip_catalog

close_project