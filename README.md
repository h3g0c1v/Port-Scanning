# Ports Scanning

This script will automate port scanning in the simplest way. The output of the script is as follows.

![image](https://github.com/h3g0c1v/enumerate/assets/66705453/3d661ad8-07a7-4907-b26d-871406ddc591)

Then the script will scan the discovered open ports for versions and services.

![image](https://github.com/h3g0c1v/enumerate/assets/66705453/a824f626-eae0-40f0-94f1-bfdf203c06e4)

If you have open http/s ports, it will run the http-enum.nse script on them.

![image](https://github.com/h3g0c1v/enumerate/assets/66705453/58906eaf-d654-4cbd-a8c6-53c62f0ffed8)

And last but not least, the script will run the whatweb program on the open http/s ports.

![image](https://github.com/h3g0c1v/enumerate/assets/66705453/72ae15e4-5a2c-4513-8f34-72c4b819438c)

Everything you are seeing is stored in the “allPorts”, “targeted” and “webScan” files.

In addition, you can hide the banner with the `--no-banner` parameter.

![image](https://github.com/h3g0c1v/enumerate/assets/66705453/0afb522a-05fa-4c5a-9fe0-e2f890e77c3d)
