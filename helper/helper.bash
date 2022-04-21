. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/ticat.helper.bash/helper.bash"

function parse_sesame_log()
{
    local log="${1}"
	local col=`cat "${log}" | awk '{print $1}' | sed ':a;N;$!ba;s/:/,/g' | sed ':a;N;$!ba;s/\n//g'`
	local val=`cat "${log}" | awk '{print $2}' | sed ':a;N;$!ba;s/s/,/g' | sed ':a;N;$!ba;s/\n//g'`
	echo "${col} ${val}"
}
