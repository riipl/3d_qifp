# Quantitative Image Feature Engine



## Installation and how to run it.
The QIFE can be run through DOCKER or natively if Matlab is present

### Matlab
#### Matlab Instalation
The QIFE has been tested with versions of MATLAB 2015b or later. 
To install download the source code from this repository to any folder and navigate to the folder from your MATLAB GUI

#### Matlab Run Instructions
There are two entry functions in the QIFE.
* `runPipeline.m` - That takes the configuration as a Matlab structure and runs the QIFE with that configuration
* `runDSOPipelineCommandLine.m` - Loads the configuration from a system file (see below for format and examples), it also sets some defaults for the pipeline. 

##### runPipeline.m
To execute:
```Matlab
runPipeline(config);
```
##### runPipeline.m
This function defaults to use the DSOLoader to load files in and assumes that DSO and DICOM images are present in the same directory.
To execute:
```Matlab
runDSOPipelineCommandLine(dsoDirPath, outputDirPath, configFilePath, qifpFormat);
```
where 
* **dsoDirPath:**  directory where one can find the DSO and Dicom files 
* **outputDirPath:**  directory where the output should be written
* **configFilePath**  configuration file
* **qifpFormat** a flag to let it know if your file is using version 0 or 1 of the config file


### Docker
#### Docker Instalation 
You need to have Docker installed
There are two versions of the dockerized QIFE:
* **Latest**: This version contains the latest bugpatches and features but has not been 100% tested
* **Stable**: This version contains all the tested components.

To download the latest image use:
```sh
$ docker pull riipl/3d_qifp:latest
```

To download the stable image use:
```sh
$ docker pull riipl/3d_qifp:stable
```

#### Docker Run Instructions
```sh
$ docker run -v DIR_TO_MOUNT:/riipl/data riipl/3d_qifp data/dicoms data/output data/config.ini 1
```

* **DIR_TO_MOUNT:**  directory you want to mount inside the docker container
* **/riipl/data/:** recommended directory to mount data directory inside the docker container 
* **data/dicoms:** directory where one can find the DSO and Dicom files 
* **data/output:**  directory where the output should be written
* **data/config.ini**  configuration file
* **1:** a flag to let it know that you are using the new config file format


## Configuration File
 There are two formats of configuration files 
### Configuration File Version 0 
 Version 0 follows the ini formatting using brackets to define sections and uses `key=value` to define settings under each section.  Spaces and semicolons are ignored.
 To define multiple values for the same configuration use a comma-separated list:
 
#### Example Version 0 Configuration File:
```ini
[global]
parallelMode="none"
numberOfProcessors="max"
uidToProcess="all"

[input]
component="dsoLoader"

[preprocessing]
components="maximumConnected,holeFilling"

[featureComputation]
components="information,size,intensity,sphericity,roughness,edgeSigmoidFitting,lvii,glcm,connectedRegions"

[output]
components="csvOutput,maxAreaImage,references"

[edgeSigmoidFitting]
numberOfNormals=1200

[csvOutput]
final=true
each=true

[maxAreaImage]
each=true
windowLevelPreset="ctLung"
```

### Configuration File Version 1
 Version 1 fmakes a modification on the ini standard by prepending sections to each key using a pipe, i.e. `section|key=value` to define settings under each section.  Spaces and semicolons are ignored.
To define multiple values for the same configuration use a comma-separated list:

#### Example Version 1 Configuration File:
```ini
global|parallelMode="none"
global|numberOfProcessors="max"
global|uidToProcess="all"

input|component="dsoLoader"
preprocessing|components="maximumConnected,holeFilling"
featureComputation|components="information,size,intensity,sphericity,roughness,edgeSigmoidFitting,lvii,glcm,connectedRegions"
output|components="csvOutput,maxAreaImage,references"

edgeSigmoidFitting|numberOfNormals=1200

csvOutput|final=true
csvOutput|each=true

maxAreaImage|each=true
maxAreaImage|windowLevelPreset="ctLung"


```

## Notes
### Features not compatible with penumbra only region
The following feature components require a closed volume, therefore their results are not defined when using penumbra-only segmentation:
* edgeSigmoidFitting
* lvii
* roughness
* sphericity
