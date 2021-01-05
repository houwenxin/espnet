for accent in en_us en_gb en_in; do
  for noise_type in noise; do
    for device in matrix nexus6 pseye respeaker shure usb; do
      train_set=${accent}_${noise_type}_${device}/train
      train_dev=${accent}_${noise_type}_${device}/test
      nohup bash run.sh --train_set ${train_set} --train_dev ${train_dev } --stop_stage 2 & >> ${accent}_${noise_type}_${device}.log
    done
  done
done
