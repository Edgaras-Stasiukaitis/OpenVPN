<template>
  <div>
    <a-modal v-model="visible" :title="record._name" :width="800" :keyboard="false" @cancel="$emit('closed')">
        <a-form :form="form" :label-col="{ span: 8 }" :wrapper-col="{ span: 12 }" @submit="handleSubmit">
            <a-form-item label="Enable">
                <a-switch v-decorator="['enable',
                { initialValue: record.enable === '1', valuePropName: 'checked' }]"/>
            </a-form-item>
            <a-form-item label="Authentication">
              <a-select
                v-decorator="['_auth',
                { initialValue: auth, rules: [{ required: true, message: 'Authentication is required!' }] }]"
                @change="onSelectChange"
              >
                <a-select-option value="skey">
                    Static key
                </a-select-option>
                <a-select-option value="tls">
                    TLS
                </a-select-option>
              </a-select>
            </a-form-item>
            <div v-if="record.type === 'server'">
                <div v-if="auth === 'skey'">
                    <a-form-item label="Local tunnel endpoint IP">
                        <a-input
                            v-decorator="['local_ip',
                            { initialValue: record.local_ip, rules: [{ required: true, validator: validateIP }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Port">
                      <a-input
                        v-decorator="['port',
                        { initialValue: record.port, rules: [{ required: true, validator: validatePort }] }]"
                      />
                    </a-form-item>
                    <a-form-item label="Remote tunnel endpoint IP">
                        <a-input
                            v-decorator="['remote_ip',
                            { initialValue: record.remote_ip, rules: [{ required: true, validator: validateIP }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Remote network IP address">
                        <a-input
                            v-decorator="['network_ip',
                            { initialValue: record.network_ip, rules: [{ validator: validateRemoteNetworkIP }] }]"
                            @change="onRemoteIpInputChange"
                        />
                    </a-form-item>
                    <a-form-item label="Remote network netmask">
                        <a-input
                            v-decorator="['network_mask',
                            { initialValue: record.network_mask, rules: [{ validator: validateRemoteNetmask }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Static key upload">
                      <upload-file certName="static.key" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                </div>
                <div v-else-if="auth === 'tls'">
                    <a-form-item label="Virtual network IP address">
                        <a-input
                            v-decorator="['server_ip',
                            { initialValue: record.server_ip, rules: [{ required: true, validator: validateIP }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Port">
                      <a-input
                        v-decorator="['port',
                        { initialValue: record.port, rules: [{ required: true, validator: validatePort }] }]"
                      />
                    </a-form-item>
                    <a-form-item label="Virtual network netmask">
                        <a-input
                            v-decorator="['server_netmask',
                            { initialValue: record.server_netmask, rules: [{ required: true, validator: validateNetmask }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Certificate authority certificate upload">
                      <upload-file certName="ca.cert.pem" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                    <a-form-item label="Server certificate upload">
                      <upload-file certName="server.cert.pem" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                    <a-form-item label="Server key upload">
                      <upload-file certName="server.key.pem" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                    <a-form-item label="Diffie Hellman parameters file upload">
                      <upload-file certName="dh.pem" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                </div>
            </div>
            <div v-else>
                <div v-if="auth === 'skey'">
                    <a-form-item label="Remote host/IP address">
                        <a-input
                            v-decorator="['remote',
                            { initialValue: record.remote, rules: [{ required: true, message: 'Remote host/IP address is required!'  }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Port">
                      <a-input
                        v-decorator="['port',
                        { initialValue: record.port, rules: [{ required: true, validator: validatePort }] }]"
                      />
                    </a-form-item>
                    <a-form-item label="Local tunnel endpoint IP">
                        <a-input
                            v-decorator="['local_ip',
                            { initialValue: record.local_ip, rules: [{ required: true, validator: validateIP }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Remote tunnel endpoint IP">
                        <a-input
                            v-decorator="['remote_ip',
                            { initialValue: record.remote_ip, rules: [{ required: true, validator: validateIP  }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Remote network IP address">
                        <a-input
                            v-decorator="['network_ip',
                            { initialValue: record.network_ip, rules: [{ validator: validateRemoteNetworkIP  }] }]"
                            @change="onRemoteIpInputChange"
                        />
                    </a-form-item>
                    <a-form-item label="Remote network netmask">
                        <a-input
                            v-decorator="['network_mask',
                            { initialValue: record.network_mask, rules: [{ validator: validateRemoteNetmask }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Static key upload">
                      <upload-file certName="static.key" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                </div>
                <div v-else-if="auth === 'tls'">
                    <a-form-item label="Remote host/IP address">
                        <a-input
                            v-decorator="['remote',
                            { initialValue: record.remote, rules: [{ required: true, message: 'Remote host/IP address is required!' }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Port">
                      <a-input
                        v-decorator="['port',
                        { initialValue: record.port, rules: [{ required: true, validator: validatePort }] }]"
                      />
                    </a-form-item>
                    <a-form-item label="Remote network IP address">
                        <a-input
                            v-decorator="['network_ip',
                            { initialValue: record.network_ip, rules: [{ validator: validateRemoteNetworkIP }] }]"
                            @change="onRemoteIpInputChange"
                        />
                    </a-form-item>
                    <a-form-item label="Remote network netmask">
                        <a-input
                            v-decorator="['network_mask',
                            { initialValue: record.network_mask, rules: [{ validator: validateRemoteNetmask }] }]"
                        />
                    </a-form-item>
                    <a-form-item label="Certificate authority certificate upload">
                      <upload-file certName="ca.cert.pem" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                    <a-form-item label="Client certificate upload">
                      <upload-file certName="client.cert.pem" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                    <a-form-item label="Client key upload">
                      <upload-file certName="client.key.pem" :configFile="configFile" :record="record" @uploaded="$emit('updated', record.id)"></upload-file>
                    </a-form-item>
                </div>
            </div>
        </a-form>
        <template slot="footer">
            <a-button key="back" @click="$emit('closed')">
              Cancel
            </a-button>
            <a-button key="submit" type="primary" @click="handleSubmit">
              Save
            </a-button>
      </template>
    </a-modal>
  </div>
</template>
<script>
import validators from '@/plugins/vuci-validator'
import UploadFile from './UploadFile.vue'

export default {
  components: {
    UploadFile
  },
  props: ['show', 'record', 'configFile'],
  data () {
    return {
      visible: false,
      auth: this.record._auth,
      remoteIp: '',
      remoteNetmask: '',
      form: this.$form.createForm(this, { name: 'coordinated' }),
      routerLanAddress: ''
    }
  },
  watch: {
    show: function () {
      this.visible = this.show
      this.form = this.$form.createForm(this, { name: 'coordinated' })
    },
    record: function () {
      if (Object.keys(this.record).length !== 0) this.load()
    }
  },
  methods: {
    load () {
      this.auth = this.record._auth
      this.remoteIp = this.record.network_ip
      this.remoteNetmask = this.record.network_mask
    },
    onRemoteIpInputChange (value) {
      this.remoteIp = value.target.value
    },
    onSelectChange (value) {
      if (this.auth === '' || this.auth == null) {
        this.$uci.set(this.configFile, this.record._name, '_auth', value)
        this.$emit('updated', this.record.id)
        return
      }
      this.auth = value
      this.checkFiles()
      this.$uci.set(this.configFile, this.record._name, '_auth', value)
      if (value === 'tls') {
        this.$uci.set(this.configFile, this.record._name, '_tls_auth', 'none')
        this.$uci.set(this.configFile, this.record._name, '_tls_cipher', 'all')
        this.$uci.set(this.configFile, this.record._name, 'auth', 'sha1')
        if (this.record.type === 'server') {
          this.$uci.set(this.configFile, this.record._name, 'tls_server', '1')
        } else {
          this.$uci.set(this.configFile, this.record._name, 'tls_client', '1')
          this.$uci.set(this.configFile, this.record._name, 'client', '1')
        }
      } else {
        this.$uci.set(this.configFile, this.record._name, '_tls_auth', '')
        this.$uci.set(this.configFile, this.record._name, '_tls_cipher', '')
        this.$uci.set(this.configFile, this.record._name, 'auth', '')
        this.$uci.set(this.configFile, this.record._name, 'tls_server', '')
        this.$uci.set(this.configFile, this.record._name, 'tls_client', '1')
        this.$uci.set(this.configFile, this.record._name, 'client', '1')
      }
      this.$emit('updated', this.record.id)
    },
    update (values) {
      for (var [key, value] of Object.entries(values)) {
        if (key === 'enable') value = value ? '1' : '0'
        this.$uci.set(this.configFile, this.record._name, key, value)
      }
      this.$emit('closed')
      this.$emit('updated', this.record.id)
      this.$message.success('Configuration successfully updated!')
    },
    handleSubmit (e) {
      e.preventDefault()
      this.form.validateFields((err, values) => {
        if (err) return
        this.update(values)
      })
    },
    validateIP (rule, value, message) {
      if (value == null || value === '') {
        message('Field cannot be empty!')
        return
      }
      if (validators.ip4addr(value)) {
        message()
        return
      }
      message('IP address is invalid!')
    },
    validatePort (rule, value, message) {
      if (value == null || value === '') {
        message('Field cannot be empty!')
        return
      }
      if (validators.port(value)) {
        message()
        return
      }
      message('Port is invalid!')
    },
    validateRemoteNetworkIP (rule, value, message) {
      if (value == null || value === '') {
        message()
        return
      }
      if (this.routerLanAddress === value) {
        message('Remote network IP address cannot be the same as router\'s LAN address!')
        return
      }
      if (validators.ip4addr(value)) {
        message()
        return
      }
      message('IP address is invalid!')
    },
    validateNetmask (rule, value, message) {
      if (value == null || value === '') {
        message('Field cannot be empty!')
        return
      }
      if (validators.netmask4(value)) {
        message()
        return
      }
      message('Netmask is invalid!')
    },
    validateRemoteNetmask (rule, value, message) {
      if (value == null || value === '') {
        message()
        return
      }
      if (!validators.netmask4(value)) {
        message('Netmask is invalid!')
        return
      }
      if (this.remoteIp == null || this.remoteIp === '') {
        message()
        return
      }
      const remoteIpInt = this.ip2int(this.remoteIp)
      const routerLanIpInt = this.ip2int(this.routerLanAddress)
      if ((routerLanIpInt & value) !== (remoteIpInt & value)) {
        message('Entered netmask is in incorrect size!')
        return
      }
      message()
    },
    ip2int (ip) {
      return ip.split('.').reduce((ipInt, octet) => ((ipInt << 8) + parseInt(octet, 10)), 0) >>> 0
    },
    checkFiles () {
      this.$rpc.call('vpn', 'delete_files', { record: this.record })
    }
  },
  mounted () {
    this.$network.load().then(() => {
      this.routerLanAddress = this.$network.getInterface('lan').status['ipv4-address'][0].address
    })
  }
}
</script>
