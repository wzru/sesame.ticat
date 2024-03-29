set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env_file="${1}/env"
env=`cat "${env_file}"`

# The meta db to create table and insert any records we want
meta_host=`env_val "${env}" 'bench.meta.host'`
if [ -z "${meta_host}" ]; then
	echo "[:-] env 'bench.meta.host' is empty, skipped" >&2
	exit
fi
meta_port=`must_env_val "${env}" 'bench.meta.port'`
meta_db=`must_env_val "${env}" 'bench.meta.db-name'`
meta_user=`must_env_val "${env}" 'bench.meta.user'`
meta_pass=`env_val "${env}" 'bench.meta.pass'`

# The context of one bench
bench_tag=`env_val "${env}" 'bench.tag'`
bench_begin=`env_val "${env}" 'bench.begin'`
bench_id=`env_val "${env}" 'bench.id'`
workload=`must_env_val "${env}" 'bench.workload'`
commit=`env_val "${env}" 'bench.commit'`

# The context of one run
run_begin=`env_val "${env}" 'bench.run.begin'`
if [ -z "${run_begin}" ]; then
	echo "[:-] env 'bench.run.begin' is empty, skipped" >&2
	exit
fi
run_end=`must_env_val "${env}" 'bench.run.end'`
run_log=`must_env_val "${env}" 'bench.run.log'`
detail=(`must_env_val "${env}" 'bench.sesame.detail' | sed 's/inf/NULL/g'`)
tag=`env_val "${env}" 'bench.tag'`

## Write the record tables if has meta db
#

function my_exe()
{
	local query="${1}"
    # echo "${query}"
if [ -z "${meta_pass}" ]; then
	mysql -h "${meta_host}" -P "${meta_port}" -u "${meta_user}" --database="${meta_db}" -e "${query}"
else
    mysql -h "${meta_host}" -P "${meta_port}" -u "${meta_user}" --password="${meta_pass}" --database="${meta_db}" -e "${query}"
fi
}

if [ -z "${meta_pass}" ]; then
    mysql -h "${meta_host}" -P "${meta_port}" -u "${meta_user}" -e "CREATE DATABASE IF NOT EXISTS ${meta_db}"
else
    mysql -h "${meta_host}" -P "${meta_port}" -u "${meta_user}" --password="${meta_pass}" -e "CREATE DATABASE IF NOT EXISTS ${meta_db}"
fi


function write_record()
{
	local table="${1}"

	my_exe "CREATE TABLE IF NOT EXISTS ${table} (  	\
                id INT PRIMARY KEY AUTO_INCREMENT, 	\
                bench_id INT,                       \
                bench_begin TIMESTAMP, 				\
                run_begin TIMESTAMP, 				\
                run_end TIMESTAMP, 					\
                tag VARCHAR(255), 					\
                commit VARCHAR(40),                 \
                algo_id INT,                        \
                algo VARCHAR(16), 					\
                workload VARCHAR(16), 				\
                num_points INT, 					\
                dim INT, 							\
                num_clusters INT, 					\
                num_res INT,                        \
                cluster_size INT,                   \
                outlier_size INT,                   \
                arr_rate INT,                       \
                max_in_nodes INT, 					\
                max_leaf_nodes INT, 				\
                distance_threshold DOUBLE, 			\
                seed INT, 							\
                coreset_size INT, 					\
                radius DOUBLE, 						\
                delta DOUBLE, 						\
                beta DOUBLE, 						\
                buf_size INT, 						\
                alpha DOUBLE, 						\
                lambda DOUBLE, 						\
                clean_interval INT, 				\
                min_weight DOUBLE, 					\
                base INT, 							\
                cm DOUBLE, 							\
                cl DOUBLE, 							\
                grid_width DOUBLE, 					\
                min_points INT, 					\
                epsilon DOUBLE, 					\
                mu DOUBLE, 							\
                num_last_arr INT,				 	\
                time_window INT, 					\
                num_online_clusters INT, 			\
                delta_grid DOUBLE, 					\
                num_samples DOUBLE, 				\
                landmark INT,                       \
                sliding INT,                        \
                outlier_distance_threshold DOUBLE,  \
                outlier_cap INT,                    \
                outlier_density_threshold DOUBLE,   \
                neighbor_distance DOUBLE,           \
                k INT,                              \
                run_offline BOOL,                   \
                num_grids INT,                      \
                gap INT,                            \
                obj INT,                            \
                queue_size_threshold INT,           \
                dim_threshold INT,                  \
                variance_threshold DOUBLE,          \
                outliers_num_threshold INT,         \
                outliers_dist_threshold DOUBLE,     \
                change_count INT,                   \
                change_log TEXT,                    \
                first_algo INT,                     \
                final_algo INT,                     \
                mig_us BIGINT,                      \
                det_us BIGINT,                      \
                win_us BIGINT,                      \
                ds_us BIGINT, 						\
                out_us BIGINT, 						\
                ref_us BIGINT, 						\
                sum_us BIGINT, 						\
                lat_us DOUBLE, 						\
                et_s DOUBLE, 						\
                on_20 DOUBLE,                       \
                on_40 DOUBLE,                       \
                on_60 DOUBLE,                       \
                on_80 DOUBLE,                       \
                on_100 DOUBLE,                      \
                qps DOUBLE, 						\
                cmm DOUBLE, 						\
                nmi DOUBLE,                         \
                purity DOUBLE, 						\
                et int GENERATED ALWAYS AS (timestampdiff(SECOND,run_begin,run_end)) VIRTUAL, \
                INDEX(bench_id),                    \
                INDEX(bench_begin), 				\
                INDEX(algo_id)   					\
			)                   					\
			"

	my_exe "INSERT INTO ${table} (                  \
		bench_begin, run_begin,                     \
        run_end, bench_id, commit,                  \
		${detail[0]} tag                            \
	)                   				            \
		VALUES (                                    \
		FROM_UNIXTIME(${bench_begin}),              \
		FROM_UNIXTIME(${run_begin}),                \
		FROM_UNIXTIME(${run_end}),                  \
        ${bench_id},                                \
        '${commit}',                                \
		${detail[1]},                               \
		\"${tag}\"                                  \
	)                                               \
	"
}

write_record 'sesame'
