# Requirements
Hunter requires a recent version of `ruby.` (>=2.5.1), and `bundler`. The following will install using `git`:

```
git clone https://github.com/openflighthpc/flight-hunter.git
cd flight-hunter
bundle install
```

The entry script is located at `bin/flight-hunter.rb`

To obtain the PXE bootable image, use Flight Images with `etc/PXE script/mycustomscript.sh`.