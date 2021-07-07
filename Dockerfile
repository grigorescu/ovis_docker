FROM centos:7 AS build

RUN yum update -y && yum group install -y "Development Tools" && \
    yum install -y cmake \
                   httpd-devel \
                   libevent-devel \
                   libyaml-devel \
                   mod_wsgi \
                   numpy \
                   openssl-devel \
                   python3 \
                   python36-devel \
                   sqlite3 \
                   which \
                   && pip3 install cython pandas

COPY sos /build_sosdb

RUN cd /build_sosdb && \
    ./autogen.sh && \
    ./configure --prefix=/usr/fake_local && \
    make && \
    make install && \
    tar czf sosdb_master.tgz -C /usr/fake_local . && \
    tar xzf sosdb_master.tgz -C /usr/local

COPY sosdb-ui /build_ui

RUN cd /build_ui && \
    ./autogen.sh && \
    ./configure --prefix=/app && \
    make && \
    make install

FROM centos:7 AS runner

RUN yum update -y && \
    yum install -y python3 && \
    pip3 install cython django==2.1.0 django-cors-headers pandas

COPY --from=build /build_sosdb/sosdb_master.tgz /usr/local

RUN tar xvzf /usr/local/sosdb_master.tgz -C /usr/local

COPY --from=build /app /app

COPY settings.py /app/sosgui/

ENV LD_LIBRARY_PATH=/usr/local/lib

WORKDIR /app

RUN mkdir -p /var/www/ovis_web_svcs && \
    cp -r templates static /var/www/ovis_web_svcs && \
    python3 manage.py migrate && \
    python3 manage.py migrate --run-syncdb && \
    echo "from sosdb_auth.models import SosdbUser; SosdbUser.objects.create_superuser('admin', 'admin@example.com', 'pass')" | python3 manage.py shell

CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]