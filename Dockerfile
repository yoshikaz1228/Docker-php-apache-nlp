FROM php:7.2.7-apache

LABEL maintainer="yoshikaz"
ENV DEBCONF_NOWARNINGS yes

RUN apt-get update \
&& apt-get install -y libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev git wget libmecab-dev locales locales-all vim unzip

RUN apt-get update \
    && apt-get install -y locales \
    && locale-gen ja_JP.UTF-8 \
    && echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

RUN cd /tmp \
    && git clone https://github.com/taku910/mecab.git \
    && cd mecab/mecab/ \
    && ./configure --enable-utf8-only --with-charset=utf8 \
    && make \
    && make install \
    && cd ../mecab-ipadic \
    && ./configure --with-charset=utf8 \
    && make \
    && make install

RUN wget -O /tmp/CRF++-0.58.tar.gz 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ' \
    && cd /tmp/ \
    && tar zxf CRF++-0.58.tar.gz \
    && cd CRF++-0.58 \
    && ./configure \
    && make \
    && make install

RUN cd /tmp \
    && DOWNLOAD_URL="https://drive.google.com`curl -c cookies.txt \
       'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU' \
       | sed -r 's/"/\n/g' |grep id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU |grep confirm |sed 's/&amp;/\&/g'`" \
    && curl -L -b cookies.txt -o /tmp/cabocha-0.69.tar.bz2 "$DOWNLOAD_URL" \
    && tar jxf cabocha-0.69.tar.bz2 \
    && cd cabocha-0.69 \
    && export CPPFLAGS=-I/usr/local/include \
    && ./configure --with-mecab-config=`which mecab-config` --with-charset=utf8 \
    && make \
    && make install
RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/lib.conf \
    && ldconfig
RUN git clone https://github.com/y-uti/php-cabocha.git \
    && cd php-cabocha \
    && phpize \
    && ./configure --with-charset=utf8 --enable-utf8-only \
    && make \
    && make install


RUN echo 'extension=cabocha.so' > /usr/local/etc/php/php.ini
RUN apachectl start

RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev

RUN mkdir tmp \
    && cd tmp \
    && mkdir Python37 \
    && cd Python37 \
    && wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz \
    && tar xvf Python-3.7.0.tar.xz \
    && cd Python-3.7.0 \
    && ./configure --enable-optimizations \
    && make altinstall \
    && mkdir /usr/local/Python \
    && cd /usr/local/Python \
    && wget https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py

RUN curl -OL https://github.com/taku910/cabocha/archive/master.zip \
 && unzip master.zip \
 && cd cabocha-master \
 && pip install python/ \
 && cd ../ \
 && git clone https://github.com/kenkov/cabocha \
 && pip install cabocha/
 
 RUN pip install regex mecab-python3

RUN usermod -u 1000 www-data \
    && groupmod -g 1000 www-data
