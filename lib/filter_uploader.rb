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
    rules = ['#!/bin/sh','cat <<EOF >> /etc/hosts']
    list.each { |url| rules << domain_hosts(url) unless url.include?('reddit') }
    rules << 'EOF'
    rules << 'killall dnsmasq'
    rules << 'dnsmasq --conf-file=/etc/dnsmasq.conf'
    list.each { |url| rules << domain_filter(url) if url.include?('reddit') }
    scp_upload(rules.join("\n"))
  end

  def update_iptables
    reboot
  end

  private

    def reboot
      ssh_cmd('flashfs save && flashfs commit && flashfs enable && reboot')
    end

    def scp_upload(data)
      Net::SCP.start( @host, @user, password: @password ) do |scp|
        return scp.upload! StringIO.new(data), "/usr/local/sbin/post-firewall"
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
      row = ["127.0.0.1 #{url}"]
      row << "www.#{url}" if url.count('.') == 1
      row.join(' ')
    end
end
