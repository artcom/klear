klear
=====

Create and manage choreographies for motors and lights on the Manta Rhei.

To understand what this is all about please check the Manta Rhei project page:

 - http://www.artcom.de/en/projects/project/detail/manta-rhei/

This gem now is the starting point for refactoring the Manta Rhei code. The klear repo will contain all code for handling the actual content. Running the stepper motors or driving the OLEDs or DMX is part of the kinetic-light-engine which goes online soon.
 
Klear file generation
---------------------

Klear files are zipped directory structures which are generated from a set of images. The pixel values directly map to motor position and light intensity. On top of that, the klear file contains some additional meta info and cache date to speed up its loading at runtime. Generating a klear file from a images sequence in a directory goes like:

    $ rvm jruby exec ./bin/klear.rb generate image_sequence_dir outfile.kle
    
and of course, more documentation needs to come (means must be converted from the internal wiki to here).
