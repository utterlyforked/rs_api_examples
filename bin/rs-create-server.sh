#!/bin/bash -e

# rs-create-server.sh <nickname> <rs_cloud_id> <deployment_id> <server_template_id> <ec2_instance_type> <nat_enabled> <ec2_ssh_key_id> <vpc_subnet_id> <ec2_security_group_ids> 
# FIXME 

# e.g. rs-create-server.sh 'Starbug' 4 281233001 252761001 't1.micro' 'on_demand' 0 209585 201548001 "126311 12345"

# Note: If using multiple ec2_security_group_ids, ensure double quotes "" are used, e.g. "126311 12345"

# RightScale (public) cloud IDs
#1  US-East
#2  Europe
#3  US-West
#4  Singapore 
#5  Tokyo
#6  Oregon
#7  SA-São Paulo (Brazil)

# Example params:
# server_template_id:252761001
# runnable[nickname]:RightScale Linux Server RL 5.8
# runnable[multi_cloud_image_id]:
# runnable[instance_type]:
# runnable[pricing]:on_demand
# runnable[max_spot_price]:0.025
# runnable[vpc_subnet_id]:
# runnable[private_ip_address]:
# runnable[nat_enabled]:0
# runnable[ec2_ssh_key_id]:298336
# runnable[ec2_elastic_ip_id]:
# runnable[associate_eip_at_launch]:0
# runnable[ec2_security_group_ids][]:261902
# runnable[ec2_security_group_ids][]:261903
# runnable[ec2_availability_zone_id]:
# runnable[ec2_placement_group_id]:
# runnable[image_uid]:
# runnable[ari_image_uid]:
# runnable[aki_image_uid]:
# runnable[ec2_user_data]:
# cloud_id:4
# runnable[server_template_id]:252761001
# runnable[deployment_id]:28079

[[ ! $1 ]] && echo 'No Server nickname ID provided.' && exit 1
[[ ! $2 ]] && echo 'No RightScale cloud ID provided.' && exit 1
[[ ! $3 ]] && echo 'No RightScale deployment ID provided.' && exit 1
[[ ! $4 ]] && echo 'No RightScale ServerTemplate ID provided.' && exit 1
[[ ! $5 ]] && echo 'No EC2 instance type provided.' && exit 1
[[ ! $6 ]] && echo 'No EC2 pricing type provided.' && exit 1
[[ ! $7 ]] && echo 'No NAT enabled option provided.' && exit 1
[[ ! $8 ]] && echo 'No EC2 SSH key ID provided.' && exit 1
[[ ! $9 ]] && echo 'No VPC subnet ID provided.' && exit 1
[[ ! $1\0 ]] && echo 'No EC2 security group IDs provided.' && exit 1

. "$HOME/.rightscale/rs_api_config.sh"
. "$HOME/.rightscale/rs_api_creds.sh"

nickname="$1"
rs_cloud_id="$2"
deployment_id="$3"
server_template_id="$4"
ec2_instance_type="$5"
nat_enabled="$6"
ec2_ssh_key_id="$7"
vpc_subnet_id="$8"
ec2_security_group_ids="$9"

# This script assumes no EIP and on_demand only
ec2_elastic_ip_id=""
ec2_pricing="on_demand"

ari_image_uid=""
aki_image_uid=""
ec2_user_data=""
image_uid=""
multi_cloud_image_id=""
ec2_availability_zone_id=""
max_spot_price="0.025"
ec2_placement_group_id=""

# In case of multiple security groups, set up the params for curl
ec2_security_group_ids_str=
for f in $ec2_security_group_ids
do
   ec2_security_group_ids_str="-d runnable[ec2_security_group_ids][]=$f $ec2_security_group_ids_str"
done

rs-login-dashboard.sh               # (run this first to ensure current session)

url="https://my.rightscale.com/acct/$rs_api_account_id/servers"
echo "POST: $url"

result=$(curl -v -S -s -X POST \
-b "$HOME/.rightscale/rs_dashboard_cookie.txt" \
-H "Referer:https://my.rightscale.com/acct/$rs_api_account_id/servers/new?cloud_id=$rs_cloud_id&deployment_id=$deployment_id" \
-H "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.82 Safari/537.1" \
-H "X-Prototype-Version:1.6.1" \
-H "X-Requested-With:XMLHttpRequest" \
-d server_template_id="$server_template_id" \
-d runnable[nickname]="$nickname" \
-d runnable[multi_cloud_image_id]="$multi_cloud_image_id" \
-d runnable[instance_type]="$ec2_instance_type" \
-d runnable[pricing]="$ec2_pricing" \
-d runnable[max_spot_price]="$max_spot_price" \
-d runnable[vpc_subnet_id]="$vpc_subnet_id" \
-d runnable[nat_enabled]="$nat_enabled" \
-d runnable[ec2_ssh_key_id]="$ec2_ssh_key_id" \
-d runnable[ec2_elastic_ip_id]="$ec2_elastic_ip_id" \
-d runnable[associate_eip_at_launch]="0" \
$ec2_security_group_ids_str \
-d runnable[ec2_availability_zone_id]="$ec2_availability_zone_id" \
-d runnable[ec2_placement_group_id]="$ec2_placement_group_id" \
-d runnable[image_uid]="$image_uid" \
-d cloud_id="$rs_cloud_id" \
-d runnable[server_template_id]="$server_template_id" \
-d runnable[associate_eip_at_launch]="0" \
-d runnable[associate_eip_at_launch]="1" \
-d runnable[deployment_id]="$deployment_id" \
-d stage_names[]="ServerTemplate" \
-d stage_names[]="Server Details" \
-d stage_names[]="Confirm" \
-d runnable[image_uid]="$image_uid" \
-d runnable[ari_image_uid]="$ari_image_uid" \
-d runnable[aki_image_uid]="$aki_image_uid" \
-d runnable[ec2_user_data]="$ec2_user_data" \
-d _=" " \
"$url" 2>&1)

echo "$result" > /tmp/rs_api_examples.output.txt

echo "$result"
