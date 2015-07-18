FROM debian:jessie
RUN apt-get update && apt-get install -y aptly bzip2 gnupg gpgv
RUN groupadd -g 1000 aptly
RUN useradd -u 1000 -g 1000 aptly
RUN mkdir -p /home/aptly
RUN chown -R aptly:aptly /home/aptly
ADD aptly.asc /home/aptly/aptly.asc
WORKDIR /home/aptly
RUN su aptly -c "gpg --import aptly.asc"
ADD trustedkeys.gpg /home/aptly/.gnupg/trustedkeys.gpg
ADD aptly.conf /home/aptly/.aptly.conf
ADD containeraptly /usr/local/bin/aptly
RUN mkdir /usr/share/bin
ADD externalaptly /usr/share/bin/aptly
RUN chmod 755 /usr/local/bin/aptly /usr/share/bin/aptly
RUN chown aptly:aptly .gnupg/trustedkeys.gpg .aptly.conf
ENV GPG_PASSPHRASE unset
USER aptly
CMD [ "/usr/local/bin/aptly" ]
