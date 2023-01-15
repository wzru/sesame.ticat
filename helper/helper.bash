. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/ticat.helper.bash/helper.bash"

function parse_sesame_log()
{
    local log="${1}"
	local col=`cat "${log}" | awk '{print $1}' | sed ':a;N;$!ba;s/:/,/g' | sed ':a;N;$!ba;s/\n//g'`
	local val=`cat "${log}" | awk '{print $2}' | sed ':a;N;$!ba;s/\n/,/g'`
	echo "${col} ${val}"
}

function timestamp()
{
	echo `date +%s`
}

function retry_cmd()
{
	local cmd="${1}"
	local retry="${2}"
	local log="${3}"
	local i=0
	local ret=0
	while [ $i -lt $retry ]; do
		echo "[-] retry $i: $cmd" >&2
		$cmd | tee "${log}"
		ret=$?
		if [ $ret -eq 0 ]; then
			break
		fi
		i=$((i+1))
	done
	return $ret
}
