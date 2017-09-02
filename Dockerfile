# Dockerfile for GTEx RNA-seq pipeline
FROM ubuntu:16.04
MAINTAINER Francois Aguet

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && apt-get install -y \
        build-essential \
        cmake \
        bowtie \
	curl \
        libboost-all-dev \
        libbz2-dev \
        libcurl3-dev \
        liblzma-dev \
        libncurses5-dev \
        libssl-dev \
        openjdk-7-jdk \
        openjdk-8-jdk \
        python2.7 \
        python-pip \
        seqtk \
	unzip \
        vim-common \
        wget \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*


#-----------------------------
# Pipeline components
#-----------------------------

# htslib
RUN cd /opt && \
    wget --no-check-certificate https://github.com/samtools/htslib/releases/download/1.4.1/htslib-1.4.1.tar.bz2 && \
    tar -xf htslib-1.4.1.tar.bz2 && rm htslib-1.4.1.tar.bz2 && cd htslib-1.4.1 && make && make install && make clean

# samtools
RUN cd /opt && \
    wget --no-check-certificate https://github.com/samtools/samtools/releases/download/1.4.1/samtools-1.4.1.tar.bz2 && \
    tar -xf samtools-1.4.1.tar.bz2 && rm samtools-1.4.1.tar.bz2 && cd samtools-1.4.1 && \
    ./configure --with-htslib=/opt/htslib-1.4.1 && make && make install && make clean

# bamtools
RUN cd /opt && \
    wget --no-check-certificate https://github.com/pezmaster31/bamtools/archive/v2.4.1.tar.gz && \
    tar -xf v2.4.1.tar.gz && rm v2.4.1.tar.gz && cd bamtools-2.4.1 && mkdir build && cd build && cmake .. && make && make install && make clean
ENV LD_LIBRARY_PATH /usr/local/lib/bamtools:$LD_LIBRARY_PATH

# Picard tools
RUN mkdir /opt/picard-tools && \
    wget --no-check-certificate -P /opt/picard-tools/ https://github.com/broadinstitute/picard/releases/download/2.9.0/picard.jar

# STAR v2.5.3a
RUN cd /opt && \
    wget --no-check-certificate https://github.com/alexdobin/STAR/archive/2.5.3a.tar.gz && \
    tar -xf 2.5.3a.tar.gz && rm 2.5.3a.tar.gz && \
    make STAR -C STAR-2.5.3a/source && make STARlong -C STAR-2.5.3a/source && \
    mv STAR-2.5.3a/source/STAR* STAR-2.5.3a/bin/Linux_x86_64/
ENV PATH /opt/STAR-2.5.3a/bin/Linux_x86_64:$PATH

# RSEM v1.3.0
RUN cd /opt && \
    wget --no-check-certificate https://github.com/deweylab/RSEM/archive/v1.3.0.tar.gz && \
    tar -xvf v1.3.0.tar.gz && rm v1.3.0.tar.gz && cd RSEM-1.3.0 && make
ENV PATH /opt/RSEM-1.3.0:$PATH

# RNA-SeQC
RUN cd /opt && \
    wget --no-check-certificate https://github.com/francois-a/rnaseqc/releases/download/v1.1.9/RNA-SeQC_1.1.9.zip && \
    unzip RNA-SeQC_1.1.9.zip -d RNA-SeQC_1.1.9 && rm RNA-SeQC_1.1.9.zip

# python modules
RUN pip install --upgrade pip && pip install tables pandas feather-format pysam==0.7.7
#RUN easy_install fisher

# kallisto v0.43.1
RUN cd /opt && \
    wget https://github.com/pachterlab/kallisto/releases/download/v0.43.1/kallisto_linux-v0.43.1.tar.gz && \
    tar -xf kallisto_linux-v0.43.1.tar.gz && rm kallisto_linux-v0.43.1.tar.gz
ENV PATH $PATH:/opt/kallisto_linux-v0.43.1

# clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# scripts
COPY src src/
