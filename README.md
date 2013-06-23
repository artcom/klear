# Kinetic Light Engine Archive - klear

Create and manage choreographies for motors and lights on the Manta Rhei. This
document describes the Kinetic Light Engine File Format which contains
Choreographies and all data needed for playing it.

To understand what this is all about please check the Manta Rhei project page:

 - http://www.artcom.de/en/projects/project/detail/manta-rhei/

This gem now is the starting point for refactoring the Manta Rhei code. The klear repo will contain all code for handling the actual content. Running the stepper motors or driving the OLEDs or DMX is part of the kinetic-light-engine which goes online soon.

## File info 

  $ klear info choreo.kle

will show what is in the file. 
 
## New File Generation

*Notice: file generation depends on jruby because of its usage of Java JAI*

Klear files are zipped directory structures which are generated from a set of images. The pixel values directly map to motor position and light intensity. On top of that, the klear file contains some additional meta info and cache date to speed up its loading at runtime. Generating a klear file from a images sequence in a directory goes like:

    $ rvm jruby exec ./bin/klear.rb generate image_sequence_dir outfile.kle
    
and of course, more documentation needs to come (means must be converted from the internal wiki to here).

## FileFormat

File of this format have the file extension "kle", e.g. "calm_05.kle"

### Layout and container Structure

A .kle File contains multiple assets, incl. source PNGs, metatdata and a derived binary file containing frames in packed binary form. The Container Format is ZIP so a .kle file is just a zip-file containing files and folders.

*Directory Layout*

* Directory 'META-INF' (mandatory)
 * 'kle.yml' containing meta-data describing aspects like framerate & more
 * 'MANIFEST.MF' containing meta-data about the kle file itself (e.g. format version)
* Directory 'frames' (mandatory)
 * Source PNGs which were used to generate the kle
* Directory 'cache' (optional)
 * File 'frames.bin' containing binary data derived from the PNGs during creation
 * further pre-processed data or application state for optimized restarts might be stored here.
* Directory 'icon'
 * contains one file 'normal.png' for a normal sized icon (150 x 110 px)

### Workflow

The initial source of a kle is a sequence of PNGs + metadata. Those are used to generate a .kle file incl. the file 'frames.bin'. The metadata is stored in 'META-INF/kle.yml' and describes aspects like fps.

If a kle file does not have frame.bin in its cache directory it can be regenerated. This is also useful for future format changes together with the manifest to detect if a frames.bin is deprecated and needs to be regenerated.

The source sequence of PNGs is stored in the KLE-file as well, which allows features like frames.bin regeneration in the first place.

### File Format Details

#### PNGs

Each single PNG represents exactly one frame and is stored with 16-bit / channel. The size of the PNGs is determined by the number of columns and rows, where each tile is 10px x 10px in size. A Column represents the state of a blade at a frame (a certain point in time). The number of columns represents the number of blades. A Row represents one aspect across all blades, e.g. an outermost light or the state of the motor.

*Example*

!Waves_00129.png!

 * We have 11 rows and 14 columns (blades)
 * The lowest row describes the motor state
 * The other rows describe the state of the lights from one direction to the other (TODO: Define the direction - what is a point of reference?)
 * The Png then is 140x110px in size.

#### Sequence of PNGs

The order of the sequence is defined by the sorting delivered by the Posix command `sort -n`. So any natural alphabetical naming to order the sequence is allowed.

The number of columns and rows must be the same for all PNGs.

*Examples*

 * `A.png, B.png, X.png` is valid sequence of 3 PNGs
 * `Test_0001.png, Test_0002.png, Test__1000.png` is a valid sequence

A sequence does not need to be consecutive (it can have gaps e.g. `01.png,10.png` is valid and the existence of e.g. 05.png is not enforced).

#### kle.yml

Contains information about how to use the frames:

 * Number of columns and rows (geometry)
 * Frames per second
 * recommended gamma value
 * Potentially a free descriptor (name)

The geometry is determined automatically by reading the first png in the png sequence and dividing width and height by 10 respectively. This relies on one tile in the png being 10x10px in size.

*Example:*
<pre>
---
 description: calm_02
 geometry:
   rows: 11
   columns: 14
 fps: 25
</pre>

#### MANIFEST.MF

The manifest contains meta information about the file and file format itself:

 * `Manifest-Version` Version of the manifest itself
 * `Kle-Version` Version of the kle-file format (e.g. `1.0`)
 * `Created-By` Tool which created this file.

*Example:*

<pre>
Manifest-Version: 1.0

Kle-Version: 1.0
Created-By: ruby-kle-generator 0.344b
</pre>

#### frames.bin

The frames.bin file contains the extracted 16-bit values sampled from each tile of the PNGs. It contains all frames and each frame contains all columns and rows.

Each 16-bit value is saved as unsigned 16 bit integer big endian (network byte order) and uses 2 bytes in frames.bin.

A PNG with 11 rows and 14 columns uses `14 x 11 x 2 bytes = 308 bytes`.

Each frame is encoded rows bottom to top and the columns from left to right.

Example of a PNG with 3 rows & cols:

      col 1   col 2   col 3
    |-------|-------|-------|
    | 27009 | 38885 | 47331 | <- row 3
    |-------|-------|-------|
    | 51027 | 51233 | 49789 | <- row 2
    |-------|-------|-------|
    | 47645 | 45039 | 41857 | <- row 1
    |-------|-------|-------|

is written as a sequence of values like:

    47645 45039 41857    51027 51233 49789    27009 38885 47331


which results in a binary big endian (network) byte order sequence like:

    0xBA1D 0xAFEF 0xA381    0xC753 0xC821 0xC27D    0x6981 0x97E5 0xB8E3

As a note: row 1 is the motor state.
