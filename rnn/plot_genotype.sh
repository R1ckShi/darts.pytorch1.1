#!/bin/bash

log=$1
zip=$2

out=./.temp/

mkdir -p $out

echo "[plot tool]: preprocessing..."
cat $log | grep "Genotype" | cut -d ' ' -f 3- | \
	awk '{print "ME_Genotypes_epoch" NR " = " $0}' | sort -t '=' -k 2 -u > $out/temp1

cat $out/temp1 >> $out/plot.py

cat genotypes.py $out/plot.py > genotypes2.py

cut -d '=' -f 1 $out/temp1 > $out/filelist
cut -d '=' -f 1 $out/temp1 | sed 's:^:python visualize2.py :g' > $out/head

paste -d ' ' $out/head - - $out/filelist < /dev/null | sed 's:$::g' >> p.sh
chmod +x p.sh

echo "[plot tool]: plotting..."
./p.sh 

echo "[plot tool]: converting..."
for i in `ls *.pdf`;do 
  convert $i $i.jpg;
  convert -resize 2000x2000 $i.jpg ${i}_re.jpg
  rm -f $i;
done

convert -delay 100 -depth 8 -layers optimize -quality 80 -loop 0 ./*_re.jpg 1.gif
zip -r $zip *.jpg 1.gif

echo "[plot tool]: cleaning..."
rm -f ME_*
rm -f *.jpg

rm -f p.sh
