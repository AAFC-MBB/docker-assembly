# Dockerfile for OLCspades genome assembly pipeline
FROM ubuntu:14.04.3

MAINTAINER Mike Knowles <michael.knowles@canada.ca>

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales

#COPY sources.list /etc/apt/sources.list
# Install various required softwares
RUN apt-get update -y -qq
RUN apt-get install -y --force-yes \
	bash \
	libexpat1-dev \
	libxml2-dev \
	libxslt-dev \
	zlib1g-dev \
	libbz2-dev \
	nano \
	xsltproc \
	fastqc \
	python \
	python-matplotlib \
	ncbi-blast+ \
	hmmer \
	openjdk-7-jdk


# Install bcl2fastq
ADD accessoryfiles /accessoryfiles
ENV BCL=bcl2fastq-1.8.4-Linux-x86_64.rpm
#WORKDIR /accessoryfiles
## Download FastQC
#RUN apt-get install -y --force-yes wget unzip && \
#    wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.4.zip && unzip fastqc_v0.11.4.zip && \
#    wget http://downloads.sourceforge.net/project/bbmap/BBMap_35.82.tar.gz &&  \
#    wget http://spades.bioinf.spbau.ru/release3.6.2/SPAdes-3.6.2-Linux.tar.gz &&\
#    wget https://downloads.sourceforge.net/project/quast/quast-3.2.tar.gz && \
#    wget http://augustus.gobics.de/binaries/augustus.2.5.5.tar.gz && \
#    wget http://busco.ezlab.org/files/BUSCO_v1.1b1.tar.gz &&\
#    for clade in bacteria eukaryota fungi; do wget http://busco.ezlab.org/files/${clade}_buscos.tar.gz; tar -zxf ${clade}_buscos.tar.gz; rm ${clade}_buscos.tar.gz; done &&\
#    apt-get remove --auto-remove  -y --force-yes wget unzip && \
#    for a in $(ls -1 *.tar.gz); do tar -zxvf $a; rm $a; done && rm *.zip

#ENV PATH /accessoryfiles/augustus.2.5.5/bin:/accessoryfiles/quast-3.2:/accessoryfiles/FastQC:/accessoryfiles/bbmap:/accessoryfiles/SPAdes-3.6.2-Linux/bin:/accessoryfiles/spades:$PATH
ENV AUGUSTUS_CONFIG_PATH /accessoryfiles/augustus.2.5.5/config/

## Check if $BCL file exists
#RUN if [ ! -f $BCL ]; then ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/Software/bcl2fastq/$BCL; fi
#RUN alien -i bcl2fastq-1.8.4-Linux-x86_64.rpm
## Remove the rpm
#RUN rm /accessoryfiles/bcl2fastq-1.8.4-Linux-x86_64.rpm
## Edited Config.pm supplied with bcl2fastq to comment out sub _validateEland subroutine that was causing bcl2fastq to fail with compilation errors
#COPY Config.pm /usr/local/lib/bcl2fastq-1.8.4/perl/Casava/Alignment/Config.pm
#
## Install XML:Simple and dependencies for bcl2fastq
#RUN curl -L http://cpanmin.us | perl - App::cpanminus
#RUN cpanm --mirror http://mirror.csclub.uwaterloo.ca/CPAN/ XML::Simple --mirror-only --force



# run this script in your cmd or entrypoint script to mount your nfs mounts
COPY pipeline /spades
ADD .git /spades
WORKDIR /spades

RUN apt-get install -y --force-yes python-pip python-dev git && \
    pip install biopython argparse regex PyYAML && \
    pip install --upgrade setuptools &&\
    apt-get remove --auto-remove  -y --force-yes python-dev python-pip git


ENV PYTHONPATH=/accessoryfiles/SPAdes-3.6.2-Linux/bin:/accessoryfiles/quast-3.2:$PYTHONPATH

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["assemble"]
# Useful commandsst
#docker build -t remotepythondocker .
#docker run -e NFS_MOUNT=192.168.1.18:/mnt/zvolume1 --privileged -it -v /home/blais/PycharmProjects/SPAdesPipeline:/spades -v /media/miseq/:/media/miseq -v /home/blais/Downloads/accessoryfiles:/accessoryfiles --name pythondocker remotepythondocker
#docker rm pythondocker

# python /spades/OLCspades/OLCspades.py -m /media/miseq/MiSeqOutput -F /mnt/zvolume1/akoziol/Pipeline_development/OLCspadesV2 -f 151218_M02466_0126_000000000-AKF4P -r1 25 -r2 25 -r /mnt/zvolume1/akoziol/WGS_Spades/spades_pipeline/SPAdesPipelineFiles/
