set -uo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

session="${1}"
env=`cat "${session}/env"`

bin=`must_env_val "${env}" 'bench.sesame.bin'`

algo=`must_env_val "${env}" 'bench.sesame.algo'`
input_file=`must_env_val "${env}" 'bench.sesame.input_file'`
num_points=`must_env_val "${env}" 'bench.sesame.num_points'`
dim=`must_env_val "${env}" 'bench.sesame.dim'`
num_clusters=`must_env_val "${env}" 'bench.sesame.num_clusters'`
arr_rate=`must_env_val "${env}" 'bench.sesame.arr_rate'`
run_offline=`must_env_val "${env}" 'bench.sesame.run_offline'`
run_eval=`must_env_val "${env}" 'bench.sesame.run_eval'`
run_cmm=`must_env_val "${env}" 'bench.sesame.run_cmm'`
run_pur=`must_env_val "${env}" 'bench.sesame.run_pur'`
max_in_nodes=`must_env_val "${env}" 'bench.sesame.max_in_nodes'`
max_leaf_nodes=`must_env_val "${env}" 'bench.sesame.max_leaf_nodes'`
distance_threshold=`must_env_val "${env}" 'bench.sesame.distance_threshold'`
seed=`must_env_val "${env}" 'bench.sesame.seed'`
coreset_size=`must_env_val "${env}" 'bench.sesame.coreset_size'`
radius=`must_env_val "${env}" 'bench.sesame.radius'`
delta=`must_env_val "${env}" 'bench.sesame.delta'`
beta=`must_env_val "${env}" 'bench.sesame.beta'`
buf_size=`must_env_val "${env}" 'bench.sesame.buf_size'`
alpha=`must_env_val "${env}" 'bench.sesame.alpha'`
lambda=`must_env_val "${env}" 'bench.sesame.lambda'`
clean_interval=`must_env_val "${env}" 'bench.sesame.clean_interval'`
min_weight=`must_env_val "${env}" 'bench.sesame.min_weight'`
base=`must_env_val "${env}" 'bench.sesame.base'`
cm=`must_env_val "${env}" 'bench.sesame.cm'`
cl=`must_env_val "${env}" 'bench.sesame.cl'`
grid_width=`must_env_val "${env}" 'bench.sesame.grid_width'`
min_points=`must_env_val "${env}" 'bench.sesame.min_points'`
epsilon=`must_env_val "${env}" 'bench.sesame.epsilon'`
mu=`must_env_val "${env}" 'bench.sesame.mu'`
num_last_arr=`must_env_val "${env}" 'bench.sesame.num_last_arr'`
time_window=`must_env_val "${env}" 'bench.sesame.time_window'`
num_online_clusters=`must_env_val "${env}" 'bench.sesame.num_online_clusters'`
delta_grid=`must_env_val "${env}" 'bench.sesame.delta_grid'`
num_samples=`must_env_val "${env}" 'bench.sesame.num_samples'`
landmark=`must_env_val "${env}" 'bench.sesame.landmark'`
sliding=`must_env_val "${env}" 'bench.sesame.sliding'`
outlier_distance_threshold=`must_env_val "${env}" 'bench.sesame.outlier_distance_threshold'`
outlier_density_threshold=`must_env_val "${env}" 'bench.sesame.outlier_density_threshold'`
outlier_cap=`must_env_val "${env}" 'bench.sesame.outlier_cap'`
neighbor_distance=`must_env_val "${env}" 'bench.sesame.neighbor_distance'`
k=`must_env_val "${env}" 'bench.sesame.k'`
obj=`must_env_val "${env}" 'bench.sesame.obj'`
queue_size_threshold=`must_env_val "${env}" 'bench.sesame.queue_size_threshold'`
dim_threshold=`must_env_val "${env}" 'bench.sesame.dim_threshold'`
variance_threshold=`must_env_val "${env}" 'bench.sesame.variance_threshold'`
outliers_num_threshold=`must_env_val "${env}" 'bench.sesame.outliers_num_threshold'`
outliers_dist_threshold=`must_env_val "${env}" 'bench.sesame.outliers_dist_threshold'`

retry=`env_val "${env}" 'bench.sesame.retry'`

if [ -z "${retry}" ]; then
  retry=5
fi

log="${session}/sesame.`date +%s%N`.log"
echo "bench.run.log=${log}" >> "${session}/env"

begin=`timestamp`

cmd="""${bin} \
--algo="${algo}" \
--input_file="${input_file}" \
--num_points="${num_points}" \
--dim="${dim}" \
--num_clusters="${num_clusters}" \
--arr_rate="${arr_rate}" \
--run_offline="${run_offline}" \
--run_eval="${run_eval}" \
--run_cmm="${run_cmm}" \
--run_pur="${run_pur}" \
--max_in_nodes="${max_in_nodes}" \
--max_leaf_nodes="${max_leaf_nodes}" \
--distance_threshold="${distance_threshold}" \
--seed="${seed}" \
--coreset_size="${coreset_size}" \
--radius="${radius}" \
--delta="${delta}" \
--beta="${beta}" \
--buf_size="${buf_size}" \
--alpha="${alpha}" \
--lambda="${lambda}" \
--clean_interval="${clean_interval}" \
--min_weight="${min_weight}" \
--base="${base}" \
--cm="${cm}" \
--cl="${cl}" \
--grid_width="${grid_width}" \
--min_points="${min_points}" \
--epsilon="${epsilon}" \
--mu="${mu}" \
--num_last_arr="${num_last_arr}" \
--time_window="${time_window}" \
--num_online_clusters="${num_online_clusters}" \
--delta_grid="${delta_grid}" \
--num_samples="${num_samples}" \
--landmark="${landmark}" \
--sliding="${sliding}" \
--outlier_distance_threshold="${outlier_distance_threshold}" \
--outlier_density_threshold="${outlier_density_threshold}" \
--outlier_cap="${outlier_cap}" \
--neighbor_distance="${neighbor_distance}" \
--k="${k}" \
--obj="${obj}" \
--queue_size_threshold="${queue_size_threshold}" \
--dim_threshold="${dim_threshold}" \
--variance_threshold="${variance_threshold}" \
--outliers_num_threshold="${outliers_num_threshold}" \
--outliers_dist_threshold="${outliers_dist_threshold}" """

retry_cmd "${cmd}" "${retry}" "${log}"

if [ $? -ne 0 ]; then
  echo "ERROR: failed to retry ${retry} times"
  exit 1
fi

end=`timestamp`
detail=`parse_sesame_log "${log}"`

echo "bench.workload=${input_file}" >> "${session}/env"
echo "bench.sesame.detail=${detail}" >> "${session}/env"
echo "bench.run.begin=${begin}" >> "${session}/env"
echo "bench.run.end=${end}" >> "${session}/env"
