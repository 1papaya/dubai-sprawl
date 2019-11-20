## Dubai Urban Sprawl Classification w/ GRASS GIS

Using GRASS GIS to classify Dubai urban sprawl with Landsat7 imagery from 1999-2014

![Result Animation](https://raw.githubusercontent.com/1papaya/dubai-sprawl/master/results/result_anim_lores.gif)

### Information
Here is an example of what can be done with GRASS GIS to perform classification of satellite imagery, in this case to measure urban sprawl of Dubai.
The polygons in `classify/classify.shp` each have the metadata `id` which are used to classify areas of the imagery as a particular land use type (0=null, 1=urban, 2=undeveloped, 3=water).

In May 2003 [Landsat 7 had a Scan Line Failure](https://landsat.gsfc.nasa.gov/landsat-7/) and as a result the source imagery afterwards is missing lots of data.
As such these results ought not be used to measure urban growth of Dubai but instead serve as an example of what's possible. Check out the source of `dubai-sprawl.sh` to see how it's all done!

### Requirements
1. Linux or MacOS
2. [GRASS GIS 6.4](https://grass.osgeo.org/grass64/)
3. [ImageMagick](https://imagemagick.org/)

### Instructions
1. `git clone https://github.com/1papaya/dubai-sprawl.git && cd dubai-sprawl`
2. `chmod +x dubai-sprawl.sh`
3. `./dubai-sprawl.sh`
