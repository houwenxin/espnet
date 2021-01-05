#!/bin/bash

# Copyright 2021 Wenxin Hou
# Apache 2.0

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <src-dir> <dst-dir> <accent> <clean/noise_type> <device>"
  echo "e.g.: $0 /root/work/espnet/egs/libriadapt/asr1/download/libriadapt_raw data/en_us_clean_matrix en-us clean matrix"
  exit 1
fi

set -euo pipefail

src=$1
dst=$2
accent=$3
noise_type=$4
device=$5

[ ! -d $src ] && echo "$0: no such directory $src" && exit 1

for split in train test; do
  current_dir=${src}/${accent}/${noise_type}
  csv_file=${split}_files_${device}.csv
  [ ! -f $current_dir/$csv_file ] && echo "$0: expected file $csv_file to exist" && exit 1
  # sed -i "s#${src}/#/data/libriadapt/#" $current_dir/${csv_file}
  mkdir -p ${current_dir}/.backup; cp $current_dir/$csv_file $current_dir/.backup || exit 1;
  sed -i "s#/data/libriadapt/#${src}/#" $current_dir/${csv_file}
  mkdir -p $dst/${split}
  
  wav_scp=$dst/${split}/wav.scp; [[ -f "$wav_scp" ]] && rm $wav_scp
  trans=$dst/${split}/text; [[ -f "$trans" ]] && rm $trans
  utt2spk=$dst/${split}/utt2spk; [[ -f "$utt2spk" ]] && rm $utt2spk
  # spk2gender=$dst/spk2gender; [[ -f $spk2gender ]] && rm $spk2gender
  # awk -F "\"*,\"*" '{print $0} {print $2}' ${split}_files_${device}.csv
  tail -n +2 $current_dir/$csv_file | sort | awk -F "\"*,\"*" '{print $1" "$1}' > $wav_scp
  tail -n +2 $current_dir/$csv_file | sort | awk -F "\"*,\"*" '{print $1" "$3}' > $trans
  tail -n +2 $current_dir/$csv_file | sort | awk -F "\"*,\"*" '{print $1" "$1}' > $utt2spk
  utils/data/get_utt2dur.sh --nj 1 $dst/${split}
  utils/utt2spk_to_spk2utt.pl $dst/${split}/utt2spk > $dst/${split}/spk2utt
  # utils/fix_data_dir.sh $dst/${split}
  utils/validate_data_dir.sh --no-feats $dst/${split} || exit 1
  rm $current_dir/${csv_file}; mv $current_dir/.backup/${csv_file} $current_dir
done

echo "$0: successfully prepared data in $dst"

exit 0
