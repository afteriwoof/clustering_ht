# clustering_ht
IDL clustering codes for separating height-time profiles of multiple CME detections


stereo-ops

cd /data/ukssdc/STEREO/stereo_work/jbyrne/Catalogue/

sswidl

plot_cluster_ht,dir='20010423',/tog,n_clusters=4




scp jbyrne@stereo-ops.stp.rl.ac.uk:/data/ukssdc/STEREO/stereo_work/jbyrne/20010423/cluster_plot_ht_txt.eps .

mv cluster_plot_ht_txt.eps ~/RAL/SIPwork_Topicalissue/images/cluster_plot_ht_txt_4_1.eps

scp jbyrne@stereo-ops.stp.rl.ac.uk:/data/ukssdc/STEREO/stereo_work/jbyrne/20010423/clustering_out_dir/cluster_plot.eps .

mv cluster_plot.eps ~/RAL/SIPwork_Topicalissue/images/cluster_plot_4_1.eps

