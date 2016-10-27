# Cleans up raw data so R can read it in as a .csv
#!/bin/bash -l

# uncomment this to do everything from scratch if this script breaks, since no backups are made
unzip -o faculty_pubs.zip -d data

cd data
 
for i in *.csv;
do
# Removes everything but /pubmed/16362825","Hum Genet.  2006 from each row
# No changes to header rows (no " in the header)
mv $i $i.old
cut -f4,9,10 -d'"' <$i.old >$i &&
rm $i.old

# Replaces header line with title,year
sed -i '' 's/Title,URL,Description,Details,ShortDetails,Resource,Type,Identifiers,Db,EntrezUID,Properties/title,year/' $i
# Gets rid of /pubmed/ in /pubmed/16362825","Hum Genet.  2006
sed -i '' 's/\/pubmed\///' $i
# Replaces ","journalname. with single , in 16362825","Hum Genet.  2006
sed -i '' 's/\",\".*  /,/' $i

# header rows (they are duplicated in places since pubmed adds one for every 50 or 200 articles)
# 	title,year
# Non-header row example (from above):
#   16362825,2006

# removes duplicate header lines
# sort -r reverse sorts (so you get the header to the top since strings come after numbers)
# -u removes duplicate lines
# There are more efficient ways to do this than cat blah | do stuff > blah but I'm lazy
sort -ru $i -o $i

# Remove files that didn't get processed correctly (removes all the header lines too)
sed -i '' -e '/^[^0-9]/d' $i
done

# Read this into R then create a new column for author and stick in author name on file
#  e.g. josee.csv
# filenames = list.files()
# for (i in filenames){
# DT = fread(i, header=T)
# DT$author = gsub( }


