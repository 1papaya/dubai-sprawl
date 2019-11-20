#!/bin/bash

data_folder=./data

# path to GRASS binaries and libraries:
export GISBASE=/usr/lib/grass64

export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH=$data_folder:$GISBASE/lib

# use process ID (PID) as lock file number:
export GIS_LOCK=$

# path to GRASS settings file
export GISRC=$HOME/.grassrc6

g.gisenv set=MAPSET="PERMANENT"
g.gisenv set=LOCATION_NAME="dubai"

# get the mapset name
mapset=`g.gisenv MAPSET`
loc=`g.gisenv LOCATION_NAME`

all_import_string=""

# loop thru data
for folder in data/*/ ; do 

  # if folder looks like our data...
  if [[ ${folder} =~ ([0-9]+)-([0-9]+)-[0-9]+ ]]; then

    # capture the year/mo of files (ex. 1999_09)
    year=${BASH_REMATCH[1]}_${BASH_REMATCH[2]} 

    import_string=""

    # delete output directory if it already exists
    # used so all data will regenerate each script run
    if [[ -d "data/dubai/$year" ]]; then
      rm -rf "data/dubai/$year"
    fi

    # make sure location exists
    mkdir -p "data/dubai"
    
    # loop thru .TIFs in each folder
    for tiff in ${folder}*.TIF ; do

      # if TIF is one that we want to import
      if [[ ${tiff} =~ B([1-8]).TIF ]]; then

        # capture which channel (ex. 1, 2, 3...)
        channel=${BASH_REMATCH[1]}

        # import the tiff, output raster (ex. 1999_09.1)
        r.in.gdal -e input=$tiff output=$year.$channel

        # builds a string like 1999_09.1@PERMANENT,1999_09.2@PERMANENT etc
        import_string=$import_string$year.$channel@$mapset,
      fi
    done
    
    # create image group with imported rasters (e.x 1999_09)
    i.group group=$year subgroup=$year input=$import_string
    i.target -c group=$year 

    # import classifier vector (e.x classify_1999_09)
    v.in.ogr -o --overwrite dsn="classify/classify.shp" output=classify_$year min_area=0.0001 type=boundary snap=-1

    # set the region of the vector equal to that of the input raster group
    g.region zoom=$year.1 --overwrite -p # vect=classify_$year

    # convert the vector to a raster layer
    v.to.rast in=classify_$year output=classify_$year type=point,line,area use=attr column=id --overwrite

    # compute spectral signature
    i.gensig group=$year subgroup=$year sig="classify_$year.sig" training=classify_$year

    # compute maximum-likelihood classification, save output raster (e.x. 1999_09.out)
    i.maxlik group=$year subgroup=$year sig="classify_$year.sig" class="$year.out" --overwrite

    # save area info about output raster
    r.stats -na input="$year.out" output="info/$year.txt"

    # smoothing
    r.neighbors input="$year.out" output="$year.out" method=mode size=3 

    # save raster output
    r.out.gdal input="$year.out" format=GTiff nodata=0 output="results/result_$year.tif"

    # convert tif to gif, remove tifs
    convert "results/result_$year.tif" -fill white -stroke black -pointsize 100 -gravity center -annotate 0 "$year" -resize 40% "results/result_$year.gif"
    rm "results/result_$year.tif"

  fi

done

# create animated gif
convert -delay 100 -loop 0 "results/result_*.gif" "result_anim.gif"
