require 'chef/resource'
require 'openssl'

class Chef
  class Resource
    class SslCertificate < Chef::Resource

      def initialize(name, run_context=nil)
        super
        @resource_name = :ssl_certificate
        @action = :create
        @allowed_actions.push(@action)
        @provider = Chef::Provider::SslCertificate

        # default values
        @namespace = Mash.new
        %w{
          common_name
          country
          city
          state
          organization
          department
          email
          key_path
          key_name
          key_dir
          key_source
          key_bag
          key_item
          key_item_key
          key_encrypted
          key_secret_file
          key_content
          cert_path
          cert_name
          cert_dir
          cert_source
          cert_bag
          cert_item
          cert_item_key
          cert_encrypted
          cert_secret_file
          cert_content
          subject_alternate_names
          chain_path
          chain_name
          chain_dir
          chain_source
          chain_bag
          chain_item
          chain_item_key
          chain_encrypted
          chain_secret_file
          chain_content
          ca_cert_path
          ca_key_path
        }.each do |var|
          self.instance_variable_set("@#{var}".to_sym, self.send("default_#{var}"))
        end
      end

      def depends_chef_vault?
        key_source == 'chef-vault' || cert_source == 'chef-vault'
      end

      # used by load_current_resource
      def load
        key = read_from_path(key_path)
        key_content(key) unless key.nil?
        cert = read_from_path(cert_path)
        cert_content(cert) unless cert.nil?
        chain = read_from_path(chain_path) unless chain_path.nil?
        chain_content(chain) unless chain.nil?
      end

      def exists?
        # chain_content is optional
        @key_content.kind_of?(String) and @cert_content.kind_of?(String) and (@chain_content.kind_of?(String) or @chain_content.nil?)
      end

      def ==(o)
        o.is_a?(self.class) and
        key_path == o.key_path and
        cert_path == o.cert_path and
        key_content == o.key_content and
        cert_content == o.cert_content and
        common_name == o.common_name
      end

      alias :===  :==

      def namespace(arg=nil)
        unless arg.nil? or arg.kind_of?(Chef::Node) or arg.kind_of?(Chef::Node::ImmutableMash)
          arg = [arg].flatten
          arg = arg.inject(node) do |n, k|
            n.respond_to?(:has_key?) && n.has_key?(k) ? n[k] : nil
          end
        end
        set_or_return(
          :namespace,
          arg,
          :kind_of => [Chef::Node, Chef::Node::ImmutableMash, Mash]
        )
      end

      def common_name(arg=nil)
        set_or_return(
          :common_name,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      alias :domain :common_name

      def country(arg=nil)
        set_or_return(
          :country,
          arg,
          :kind_of => [String]
        )
      end

      def city(arg=nil)
        set_or_return(
          :city,
          arg,
          :kind_of => [String]
        )
      end

      def state(arg=nil)
        set_or_return(
          :state,
          arg,
          :kind_of => [String]
        )
      end

      def organization(arg=nil)
        set_or_return(
          :organization,
          arg,
          :kind_of => [String]
        )
      end

      def department(arg=nil)
        set_or_return(
          :department,
          arg,
          :kind_of => [String]
        )
      end

      def email(arg=nil)
        set_or_return(
          :email,
          arg,
          :kind_of => [String]
        )
      end

      def time(arg=nil)
        set_or_return(
          :time,
          arg,
          :kind_of => [Fixnum, String, Time],
          :default => 10 * 365 * 24 * 60 * 60
        )
      end

      # some common (key + cert) public methods

      def years(arg)
        unless [Fixnum, String].inject(false) { |p, v| p ||= arg.kind_of?(v) }
          raise Exceptions::ValidationFailed, "Option years must be a kind of #{to_be}! You passed #{arg.inspect}."
        end
        time(arg.to_i * 365 * 24 * 60 * 60)
      end

      def dir(arg)
        key_dir(arg)
        cert_dir(arg)
        chain_dir(arg)
      end

      def source(arg)
        key_source(arg)
        cert_source(arg)
        chain_source(arg)
      end

      def bag(arg)
        key_bag(arg)
        cert_bag(arg)
        chain_bag(arg)
      end

      def item(arg)
        key_item(arg)
        cert_item(arg)
        chain_item(arg)
      end

      def encrypted(arg)
        key_encrypted(arg)
        cert_encrypted(arg)
        chain_encrypted(arg)
      end

      def secret_file(arg)
        key_secret_file(arg)
        cert_secret_file(arg)
        chain_secret_file(arg)
      end

      # key public methods

      def key_name(arg=nil)
        set_or_return(
          :key_name,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def key_dir(arg=nil)
        set_or_return(
          :key_dir,
          arg,
          :kind_of => String
        )
      end

      def key_path(arg=nil)
        set_or_return(
          :key_path,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def key_source(arg=nil)
        set_or_return(
          :key_source,
          arg,
          :kind_of => String
        )
      end

      def key_bag(arg=nil)
        set_or_return(
          :key_bag,
          arg,
          :kind_of => String
        )
      end

      def key_item(arg=nil)
        set_or_return(
          :key_item,
          arg,
          :kind_of => String
        )
      end

      def key_item_key(arg=nil)
        set_or_return(
          :key_item_key,
          arg,
          :kind_of => String
        )
      end

      def key_encrypted(arg=nil)
        set_or_return(
          :key_encrypted,
          arg,
          :kind_of => [TrueClass, FalseClass]
        )
      end

      def key_secret_file(arg=nil)
        set_or_return(
          :key_secret_file,
          arg,
          :kind_of => String
        )
      end

      def key_content(arg=nil)
        set_or_return(
          :key_content,
          arg,
          :kind_of => String
        )
      end

      # cert public methods

      def cert_name(arg=nil)
        set_or_return(
          :cert_name,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def cert_dir(arg=nil)
        set_or_return(
          :cert_dir,
          arg,
          :kind_of => String
        )
      end

      def cert_path(arg=nil)
        set_or_return(
          :cert_path,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def cert_source(arg=nil)
        set_or_return(
          :cert_source,
          arg,
          :kind_of => String
        )
      end

      def cert_bag(arg=nil)
        set_or_return(
          :cert_bag,
          arg,
          :kind_of => String
        )
      end

      def cert_item(arg=nil)
        set_or_return(
          :cert_item,
          arg,
          :kind_of => String
        )
      end

      def cert_item_key(arg=nil)
        set_or_return(
          :cert_item_key,
          arg,
          :kind_of => String
        )
      end

      def cert_encrypted(arg=nil)
        set_or_return(
          :cert_encrypted,
          arg,
          :kind_of => [TrueClass, FalseClass]
        )
      end

      def cert_secret_file(arg=nil)
        set_or_return(
          :cert_secret_file,
          arg,
          :kind_of => String
        )
      end

      def cert_content(arg=nil)
        set_or_return(
          :cert_content,
          arg,
          :kind_of => String
        )
      end

      def subject_alternate_names(arg=nil)
        set_or_return(
          :subject_alternate_names,
          arg,
          :kind_of => Array
        )
      end

      # chain public methods

      def chain_name(arg=nil)
        set_or_return(
          :chain_name,
          arg,
          :kind_of => String,
          :required => false
        )
      end

      def chain_dir(arg=nil)
        set_or_return(
          :chain_dir,
          arg,
          :kind_of => String
        )
      end

      def chain_path(arg=nil)
        set_or_return(
          :chain_path,
          arg,
          :kind_of => String,
          :required => false
        )
      end

      def chain_source(arg=nil)
        set_or_return(
          :chain_source,
          arg,
          :kind_of => String
        )
      end

      def chain_bag(arg=nil)
        set_or_return(
          :chain_bag,
          arg,
          :kind_of => String
        )
      end

      def chain_item(arg=nil)
        set_or_return(
          :chain_item,
          arg,
          :kind_of => String
        )
      end

      def chain_item_key(arg=nil)
        set_or_return(
          :chain_item_key,
          arg,
          :kind_of => String
        )
      end

      def chain_encrypted(arg=nil)
        set_or_return(
          :chain_encrypted,
          arg,
          :kind_of => [TrueClass, FalseClass]
        )
      end

      def chain_secret_file(arg=nil)
        set_or_return(
          :chain_secret_file,
          arg,
          :kind_of => String
        )
      end

      def chain_content(arg=nil)
        set_or_return(
          :chain_content,
          arg,
          :kind_of => String
        )
      end

      # CA cert definition

      def ca_cert_path(arg=nil)
        set_or_return(
          :ca_cert_path,
          arg,
          :kind_of => String,
        )
      end

      def ca_key_path(arg=nil)
        set_or_return(
          :ca_key_path,
          arg,
          :kind_of => String,
        )
      end

      private

      # key private methods

      def default_key_path
        lazy { @default_key_path ||= ::File.join(key_dir, key_name) }
      end

      def default_common_name
        lazy { read_namespace('common_name') || node['fqdn'] }
      end

      def default_country
        lazy { read_namespace('country') }
      end

      def default_city
        lazy { read_namespace('city') }
      end

      def default_state
        lazy { read_namespace('state') }
      end

      def default_organization
        lazy { read_namespace('organization') }
      end

      def default_department
        lazy { read_namespace('department') }
      end

      def default_email
        lazy { read_namespace('email') }
      end

      def default_key_name
        "#{name}.key"
      end

      def default_key_dir
        case node['platform']
        when 'debian', 'ubuntu'
          '/etc/ssl/private'
        when 'redhat', 'centos', 'fedora', 'scientific', 'amazon'
          '/etc/pki/tls/private'
        else
          '/etc'
        end
      end

      def default_key_source
        lazy do
          read_namespace(['ssl_key', 'source'])
        end
      end

      def default_key_bag
        lazy do
          read_namespace(['ssl_key', 'bag']) or
          read_namespace('bag')
        end
      end

      def default_key_item
        lazy do
          read_namespace(['ssl_key', 'item']) or
          read_namespace('item')
        end
      end

      def default_key_item_key
        lazy { read_namespace(['ssl_key', 'item_key']) }
      end

      def default_key_encrypted
        lazy do
          read_namespace(['ssl_key', 'encrypted']) or
          read_namespace('encrypted')
        end
      end

      def default_key_secret_file
        lazy do
          read_namespace(['ssl_key', 'secret_file']) or
          read_namespace('secret_file')
        end
      end

      def default_key_content
        # TODO needs to be cached?
        lazy do
          @default_key_content ||= begin
            case key_source
            when 'attribute'
              content = read_namespace(['ssl_key', 'content'])
              if content.kind_of?(String)
                content
              else
                Chef::Application.fatal!('Cannot read SSL key from content key value')
              end
            when 'data-bag'
              read_from_data_bag(key_bag, key_item, key_item_key, key_encrypted, key_secret_file) or
                Chef::Application.fatal!("Cannot read SSL key from data bag: #{key_bag}.#{key_item}->#{key_item_key}")
            when 'chef-vault'
              read_from_chef_vault(key_bag, key_item, key_item_key) or
                Chef::Application.fatal!("Cannot read SSL key from chef-vault: #{key_bag}.#{key_item}->#{key_item_key}")
            when 'file'
              read_from_path(key_path) or
                Chef::Application.fatal!("Cannot read SSL key from path: #{key_path}")
            when 'self-signed', nil
              content = read_from_path(key_path)
              unless content
                content = generate_key
                updated_by_last_action(true)
              end
              content
            else
              Chef::Application.fatal!("Cannot read SSL key, unknown source: #{key_source}")
            end
          end # @default_key_content ||=
        end # lazy
      end

      # cert private methods

      def default_cert_path
        lazy { @default_cert_path ||= ::File.join(cert_dir, cert_name) }
      end

      def default_cert_name
        "#{name}.pem"
      end

      def default_cert_dir
        case node['platform']
        when 'debian', 'ubuntu'
          '/etc/ssl/certs'
        when 'redhat', 'centos', 'fedora', 'scientific', 'amazon'
          '/etc/pki/tls/certs'
        else
          '/etc'
        end
      end

      def default_cert_source
        lazy do
          read_namespace(['ssl_cert', 'source'])
        end
      end

      def default_cert_bag
        lazy do
          read_namespace(['ssl_cert', 'bag']) or
          read_namespace('bag')
        end
      end

      def default_cert_item
        lazy do
          read_namespace(['ssl_cert', 'item']) or
          read_namespace('item')
        end
      end

      def default_cert_item_key
        lazy { read_namespace(['ssl_cert', 'item_key']) }
      end

      def default_cert_encrypted
        lazy do
          read_namespace(['ssl_cert', 'encrypted']) or
          read_namespace('encrypted')
        end
      end

      def default_cert_secret_file
        lazy do
          read_namespace(['ssl_cert', 'secret_file']) or
          read_namespace('secret_file')
        end
      end

      def default_subject_alternate_names
        lazy do
          read_namespace(['ssl_cert', 'subject_alternate_names'])
        end
      end

      def cert_subject
        s = {}
        s['common_name'] = common_name unless common_name.nil?
        s['country'] = country unless country.nil?
        s['city'] = city unless city.nil?
        s['state'] = state unless state.nil?
        s['organization'] = organization unless organization.nil?
        s['department'] = department unless department.nil?
        s['email'] = email unless email.nil?
        s
      end

      def default_cert_content
        lazy do
          @default_cert_content ||= begin
            case cert_source
            when 'attribute'
              content = read_namespace(['ssl_cert', 'content'])
              if content.kind_of?(String)
                content
              else
                Chef::Application.fatal!('Cannot read SSL certificate from content key value')
              end
            when 'data-bag'
              read_from_data_bag(cert_bag, cert_item, cert_item_key, cert_encrypted, cert_secret_file) or
                Chef::Application.fatal!("Cannot read SSL certificate from data bag: #{cert_bag}.#{cert_item}->#{cert_item_key}")
            when 'chef-vault'
              read_from_chef_vault(cert_bag, cert_item, cert_item_key) or
                Chef::Application.fatal!("Cannot read SSL certificate from chef-vault: #{cert_bag}.#{cert_item}->#{cert_item_key}")
            when 'file'
              read_from_path(cert_path) or
                Chef::Application.fatal!("Cannot read SSL certificate from path: #{cert_path}")
            when 'self-signed', nil
              content         = read_from_path(cert_path)
              unless content and verify_self_signed_cert(key_content, content, cert_subject, nil)
                Chef::Log.debug("Generating new self-signed certificate: #{name}.")
                content = generate_cert(key_content, cert_subject, time)
                updated_by_last_action(true)
              end
              content
            when 'with-ca'
              content         = read_from_path(cert_path)
              ca_cert_content = read_from_path(ca_cert_path) or
                Chef::Application.fatal!("Cannot read CA certificate from path: #{ca_cert_path}")
              ca_key_content  = read_from_path(ca_key_path) or
                Chef::Application.fatal!("Cannot read CA key from path: #{ca_key_path}")
              unless content and verify_self_signed_cert(key_content, content, cert_subject, ca_cert_content)
                Chef::Log.debug("Generating new certificate: #{name} from given CA.")
                content = generate_cert(key_content, cert_subject, time, ca_cert_content, ca_key_content)
                updated_by_last_action(true)
              end
              content
            else
              Chef::Application.fatal!("Cannot read SSL cert, unknown source: #{cert_source}")
            end
          end # @default_cert_content ||=
        end # lazy
      end

      # chain private methods

      def default_chain_path
        lazy do
          if not chain_name.nil?
            @default_chain_path ||= ::File.join(chain_dir, chain_name)
          end
        end
      end

      def default_chain_name
        lazy do
          read_namespace(['ssl_chain', 'name'])
        end
      end

      def default_chain_dir
        case node['platform']
        when 'debian', 'ubuntu'
          '/etc/ssl/certs'
        when 'redhat', 'centos', 'fedora', 'scientific', 'amazon'
          '/etc/pki/tls/certs'
        else
          '/etc'
        end
      end

      def default_chain_source
        lazy do
          read_namespace(['ssl_chain', 'source'])
        end
      end

      def default_chain_bag
        lazy do
          read_namespace(['ssl_chain', 'bag']) or
          read_namespace('bag')
        end
      end

      def default_chain_item
        lazy do
          read_namespace(['ssl_chain', 'item']) or
          read_namespace('item')
        end
      end

      def default_chain_item_key
        lazy { read_namespace(['ssl_chain', 'item_key']) }
      end

      def default_chain_encrypted
        lazy do
          read_namespace(['ssl_chain', 'encrypted']) or
          read_namespace('encrypted')
        end
      end

      def default_chain_secret_file
        lazy do
          read_namespace(['ssl_chain', 'secret_file']) or
          read_namespace('secret_file')
        end
      end

      def default_chain_content
        lazy do
          @default_chain_content ||= begin
            case chain_source
            when 'attribute'
              content = read_namespace(['ssl_chain', 'content'])
              if content.kind_of?(String)
                content
              else
                Chef::Application.fatal!('Cannot read SSL intermediary chain from content key value')
              end
            when 'data-bag'
              read_from_data_bag(chain_bag, chain_item, chain_item_key, chain_encrypted, chain_secret_file) or
                Chef::Application.fatal!("Cannot read SSL intermediary chain from data bag: #{chain_bag}.#{chain_item}->#{chain_item_key}")
            when 'chef-vault'
              read_from_chef_vault(chain_bag, chain_item, chain_item_key) or
                Chef::Application.fatal!("Cannot read SSL intermediary chain from chef-vault: #{chain_bag}.#{chain_item}->#{chain_item_key}")
            when 'file'
              read_from_path(chain_path) or
                Chef::Application.fatal!("Cannot read SSL intermediary chain from path: #{chain_path}")
            else
              Chef::Log.debug("No SSL intermediary chain provided.")
              nil
            end
          end # @default_chain_content ||=
        end # lazy
      end

      # ca cert private methods

      def default_ca_cert_path
        lazy { read_namespace(['ca_cert_path']) }
      end

      def default_ca_key_path
        lazy { read_namespace(['ca_key_path']) }
      end

      # reading private methods

      # read some values from node namespace avoiding exceptions
      def read_namespace(ary)
        ary = [ary].flatten
        if ary.kind_of?(Array)
          ary.inject(namespace) do |n, k|
            n.respond_to?(:has_key?) && n.has_key?(k) ? n[k] : nil
          end
        end
      end

      def read_from_path(path)
        if ::File.exists?(path)
          ::IO.read(path)
        end
      end

      def read_from_data_bag(bag, item, item_key, encrypted = false, secret_file = nil)
        begin
          if encrypted
            item = Chef::EncryptedDataBagItem.load(bag, item, secret_file)
          else
            item = Chef::DataBagItem.load(bag, item)
          end
          item[item_key.to_s]
        rescue Exception => e
          Chef::Log.error(e.message)
          Chef::Log.error("Backtrace:\n#{e.backtrace.join("\n")}\n")
          nil
        end
      end

      def read_from_chef_vault(bag, item, item_key)
        require 'chef-vault'

        begin
          item = ChefVault::Item.load(bag, item)
          item[item_key.to_s]
        rescue Exception => e
          Chef::Log.error(e.message)
          Chef::Log.error("Backtrace:\n#{e.backtrace.join("\n")}\n")
          nil
        end
      end

      # ssl generation private methods

      def generate_key
        OpenSSL::PKey::RSA.new(2048).to_pem
      end

      def generate_cert_subject(s)
        name = if s.kind_of?(Hash)
          n = []
          n.push(['C', s['country'].to_s, OpenSSL::ASN1::PRINTABLESTRING]) unless s['country'].nil?
          n.push(['ST', s['state'].to_s, OpenSSL::ASN1::PRINTABLESTRING]) unless s['state'].nil?
          n.push(['L', s['city'].to_s, OpenSSL::ASN1::PRINTABLESTRING]) unless s['city'].nil?
          n.push(['O', s['organization'].to_s, OpenSSL::ASN1::UTF8STRING]) unless s['organization'].nil?
          n.push(['OU', s['department'].to_s, OpenSSL::ASN1::UTF8STRING]) unless s['department'].nil?
          n.push(['CN', s['common_name'].to_s, OpenSSL::ASN1::UTF8STRING]) unless s['common_name'].nil?
          n.push(['emailAddress', s['email'].to_s, OpenSSL::ASN1::UTF8STRING]) unless s['email'].nil?
          n
        else
          [['CN', s.to_s, OpenSSL::ASN1::UTF8STRING]]
        end
        OpenSSL::X509::Name.new(name)
      end

      def create_csr(key, subject)
        csr            = OpenSSL::X509::Request.new
        csr.version    = 0
        csr.subject    = generate_cert_subject(subject)
        csr.public_key = key.public_key
        csr.sign key, OpenSSL::Digest::SHA1.new
        csr
      end

      def generate_cert(key, subject, time, ca_cert_content = nil, ca_key_content = nil)
        # based on https://gist.github.com/nickyp/886884
        key  = OpenSSL::PKey::RSA.new(key)
        ef   = OpenSSL::X509::ExtensionFactory.new
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = OpenSSL::BN.rand(160)
        cert.not_before = Time.now
        if time.kind_of?(Time)
          cert.not_after = time
        else
          cert.not_after = cert.not_before + time.to_i
        end
        if ca_cert_content && ca_key_content
          generate_self_signed_cert_with_ca(key, cert, ef, subject, ca_cert_content, ca_key_content)
        else
          generate_self_signed_cert_without_ca(key, cert, ef, subject)
        end
      end

      def generate_self_signed_cert_without_ca(key, cert, ef, subject)
        cert.subject    = generate_cert_subject(subject)
        cert.issuer     = cert.subject # self-signed
        cert.public_key = key.public_key

        ef.subject_certificate = cert
        ef.issuer_certificate  = cert
        cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', true))
        cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash', false))
        cert.add_extension(ef.create_extension('authorityKeyIdentifier', 'keyid:always,issuer:always', false))
        if subject_alternate_names
          handle_subject_alternative_names(cert, ef, subject_alternate_names)
        end
        cert.sign(key, OpenSSL::Digest::SHA256.new)
        cert.to_pem
      end

      def generate_self_signed_cert_with_ca(key, cert, ef, subject, ca_cert_content, ca_key_content)
        ca_cert = OpenSSL::X509::Certificate.new(ca_cert_content)
        ca_key  = OpenSSL::PKey::RSA.new(ca_key_content)

        csr             = create_csr(key, subject)
        cert.subject    = csr.subject
        cert.public_key = csr.public_key
        cert.issuer     = ca_cert.subject

        ef.subject_certificate = cert
        ef.issuer_certificate  = ca_cert

        cert.add_extension ef.create_extension('basicConstraints', 'CA:FALSE')
        cert.add_extension ef.create_extension('subjectKeyIdentifier', 'hash')
        cert.add_extension ef.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')

        if subject_alternate_names
          handle_subject_alternative_names(cert, ef, subject_alternate_names)
        end
        cert.sign(ca_key, OpenSSL::Digest::SHA256.new)
        cert.to_pem
      end

      # Subject Alternative Names support taken and modified from
      # https://github.com/cchandler/certificate_authority/blob/master/lib/certificate_authority/signing_request.rb
      def handle_subject_alternative_names(cert, factory, alt_names)
        raise 'alt_names must be an Array' unless alt_names.is_a?(Array)

        name_list = alt_names.map { |m| "DNS:#{m}" }.join(',')
        ext = factory.create_ext('subjectAltName', name_list, false)
        cert.add_extension(ext)
      end

      def verify_self_signed_cert(key, cert, hostname, ca_cert_content = nil)
        key = OpenSSL::PKey::RSA.new(key)
        cert = OpenSSL::X509::Certificate.new(cert)
        cur_subject = cert.subject
        new_subject = generate_cert_subject(cert_subject)
        Chef::Log.debug("Self-signed SSL cert current subject: #{cur_subject.to_s}")
        Chef::Log.debug("Self-signed SSL cert new subject: #{new_subject.to_s}")
        if ca_cert_content
          ca_cert = OpenSSL::X509::Certificate.new(ca_cert_content)
          cur_subject.cmp(new_subject) == 0 && cert.issuer.cmp(ca_cert.subject) && cert.verify(ca_cert.public_key)
        else
          key.params['n'] == cert.public_key.params['n'] && cur_subject.cmp(new_subject) == 0 && cert.issuer.cmp(cur_subject) == 0
        end
      end

    end
  end
end
