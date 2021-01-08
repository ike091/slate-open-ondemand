FROM centos:7

# Install Open OnDemand
RUN yum update -y && \ 
    yum install -y centos-release-scl && \
    yum install -y https://yum.osc.edu/ondemand/1.8/ondemand-release-web-1.8-1.noarch.rpm && \
    yum install -y ondemand ondemand-selinux

# Open ports in firewall
RUN iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT && \ 
    iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT && \
    iptables-save > /etc/sysconfig/iptables

# Start Apache
CMD systemctl start httpd24-httpd
CMD systemctl enable httpd24-httpd

# TODO: Add SSL support

