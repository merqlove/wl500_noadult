require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'uri/open-scp'

class FilterUploader
  attr_accessor :host, :user, :password

  def initialize(params={})
    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
  end

  def upload_list(list)
    rules = ['#!/bin/sh','cat <<EOF > /etc/dnsmasq.block.conf']
    list.each { |url| rules << domain_hosts(url) unless url.include?('reddit') }
    rules << 'EOF'
    rules << 'echo "conf-file=/etc/dnsmasq.block.conf" >> /etc/dnsmasq.conf'
    rules << 'killall dnsmasq'
    rules << 'dnsmasq --conf-file=/etc/dnsmasq.conf'
    list.each { |url| rules << domain_filter(url) if url.include?('reddit') }
    upload_post_firewall(rules.join("\n"))
  end

  def update_flash
    reboot
  end

  private

    def reboot
      ssh_cmd('flashfs save && flashfs commit && flashfs enable && reboot')
    end

    def upload_post_mount(data)
      scp_upload "/usr/local/sbin/post-mount", data
    end

    def upload_post_firewall(data)
      scp_upload "/usr/local/sbin/post-firewall", data
    end

    def scp_upload(file, data)
      Net::SCP.start( @host, @user, password: @password ) do |scp|
        return scp.upload! StringIO.new(data), file
      end
    end

    def ssh_cmd(cmd)
      Net::SSH.start( @host, @user, password: @password ) do |ssh|
        if cmd.kind_of?(Array)
          puts cmd.map { |c| ssh.exec!(wrap_path(c)) }
        else
          results = ssh.exec!(wrap_path(cmd))
          puts results
        end
      end
    end

    def wrap_path(cmd)
      "export PATH=$PATH:/sbin:/usr/sbin:/opt/bin:/opt/sbin && #{cmd}"
    end

    def domain_filter(url)
      "iptables -I FORWARD -p tcp  -m webstr --url \"#{url}\" -j REJECT --reject-with tcp-reset"
    end

    def domain_hosts(url)
      "address=/#{url}/127.0.0.1"
    end
end
