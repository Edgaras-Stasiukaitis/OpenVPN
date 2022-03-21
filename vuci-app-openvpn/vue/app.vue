<template>
  <div>
    <instance-config-modal :show="showModal" :configFile="configFile" :record="record" @closed="showModal=false" @updated="saveConfig"></instance-config-modal>
    <a-table :data-source="instances" :columns="columns" :row-key="record => record.id">
      <template v-slot:instanceName="record">{{ `${record._name}_${record.type}` }}</template>
      <template v-slot:status="record">
        <a-tag :color="getStatus(record).color">{{ getStatus(record).status }}</a-tag>
      </template>
      <template v-slot:action="record">
        <a-button :type="record.enable === '1' ? 'danger' : 'primary'" size="small" style="margin-right: 5px" @click="changeState(record)" ghost><a-icon :type="record.enable === '1' ? 'caret-down' : 'caret-up'" />{{ record.enable === '1' ? 'Disable' : 'Enable' }}</a-button>
        <a-button type="primary" size="small" style="margin-right: 5px" @click="edit(record)"><a-icon type="edit" />Edit</a-button>
        <a-popconfirm @confirm="del(record)" placement="left" title="Are you sure you want to delete this instance?">
          <a-button type="danger" size="small"><a-icon type="delete" />Delete</a-button>
        </a-popconfirm>
      </template>
    </a-table>
    <div class="header">Create new instance</div>
    <a-form :form="form" :label-col="{ span: 9 }" :wrapper-col="{ span: 6 }" @submit="handleAdd">
      <a-form-item label="Name">
        <a-input
          placeholder="Input name of the instance"
          v-decorator="['name', { rules: [{ required: true, validator: validateName }] }]"
        />
      </a-form-item>
      <a-form-item label="Role">
        <a-select
          v-decorator="[
            'role',
            { initialValue: 'server', rules: [{ required: true, message: 'Role is required!' }] },
          ]"
          placeholder="Select role of the instance"
        >
          <a-select-option value="server">server</a-select-option>
          <a-select-option value="client">client</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item :wrapper-col="{ span: 6, offset: 9 }">
        <a-button type="primary" html-type="submit" block>
          Add instance
        </a-button>
      </a-form-item>
    </a-form>
  </div>
</template>

<script>
import InstanceConfigModal from './components/InstanceConfigModal.vue'

export default {
  components: {
    InstanceConfigModal
  },
  data () {
    return {
      columns: [
        { title: 'Instance', scopedSlots: { customRender: 'instanceName' } },
        { dataIndex: 'type', title: 'Role', scopedSlots: { customRender: 'role' } },
        { title: 'Status', scopedSlots: { customRender: 'status' } },
        { key: 'action', title: 'Actions', width: 300, scopedSlots: { customRender: 'action' } }
      ],
      configFile: 'openvpn',
      record: {},
      ubusData: {},
      instances: [],
      form: this.$form.createForm(this, { name: 'coordinated' }),
      showModal: false
    }
  },
  methods: {
    async load (id, name = '') {
      await this.$uci.load(this.configFile)
      this.instances = Object.values(this.$uci.state.values.openvpn).map((v, i) => {
        v.id = i
        return v
      })
      this.getServiceList()
      if (id != null) this.record = this.instances.filter(instance => instance.id === id)[0]
      if (name) {
        this.record = this.instances.filter(instance => instance._name === name)[0]
        this.showModal = true
      }
    },
    saveConfig (id, name) {
      this.$spin()
      this.$uci.save().then(() => {
        this.$uci.apply().then(() => {
          this.load(id, name)
          this.$spin(false)
        })
      })
    },
    getStatus (record) {
      if (record.enable === '0') return { color: 'red', status: 'Disabled' }
      switch (record.type) {
        case 'server':
          if (this.ubusData[record._name] == null) return { color: 'blue', status: 'Inactive' }
          if (record.enable === '1' && this.ubusData[record._name].running) return { color: 'green', status: 'Active' }
          else return { color: 'blue', status: 'Inactive' }
        case 'client':
          if (record.enable === '1' && record.status != null) return { color: 'green', status: 'Connected' }
          else return { color: 'blue', status: 'Disconnected' }
        default:
          return { color: 'red', status: 'INVALID ROLE' }
      }
    },
    changeState (record) {
      record.enable === '1'
        ? this.$uci.set(this.configFile, record._name, 'enable', '0')
        : this.$uci.set(this.configFile, record._name, 'enable', '1')
      this.saveConfig()
    },
    add (name, type) {
      this.$uci.add(this.configFile, 'openvpn', name)
      this.$uci.set(this.configFile, name, '_name', name)
      this.$uci.set(this.configFile, name, 'type', type)
      this.$uci.set(this.configFile, name, '_auth', 'skey')
      this.$uci.set(this.configFile, name, 'enable', '0')
      this.$uci.set(this.configFile, name, 'keepalive', '10 120')
      this.$uci.set(this.configFile, name, 'persist_key', '1')
      this.$uci.set(this.configFile, name, 'persist_tun', '1')
      this.$uci.set(this.configFile, name, 'dev', `tun_${type === 'server' ? 's' : 'c'}_${name}`)
      this.$uci.set(this.configFile, name, 'verb', '5')
      this.$uci.set(this.configFile, name, 'proto', 'udp')
      this.$uci.set(this.configFile, name, 'data_ciphers', ['BF-CBC'])
      this.$uci.set(this.configFile, name, 'cipher', 'BF-CBC')
      this.$uci.set(this.configFile, name, 'comp_lzo', 'no')
      switch (type) {
        case 'server':
          break
        case 'client':
          this.$uci.set(this.configFile, name, 'nobind', '1')
          this.$uci.set(this.configFile, name, 'resolv_retry', 'infinite')
          break
      }
      this.saveConfig(null, name)
    },
    edit (record) {
      this.record = record
      this.showModal = true
    },
    del (record) {
      this.$uci.del('openvpn', record._name)
      this.$rpc.call('vpn', 'delete_files', { record }).then(_ => {
        this.saveConfig()
      })
    },
    handleAdd (e) {
      e.preventDefault()
      this.form.validateFields((err, values) => {
        if (err) return
        for (let i = 0; i < this.instances.length; i++) {
          if (this.instances[i]._name === values.name) {
            this.$message.error('Name is already in use')
            return
          }
          if (values.role === 'server' && this.instances[i].type === values.role) {
            this.$message.error('Cannot create a new server instance, because one already exists')
            return
          }
        }
        this.add(values.name, values.role)
        this.$message.success('Instance successfully created!', 5)
        this.form = this.$form.createForm(this, { name: 'coordinated' })
      })
    },
    validateName (rule, value, message) {
      if (value == null || value === '') {
        message('Name cannot be empty!')
        return
      }
      if (value.length > 8) {
        message('Name cannot contain more than 8 characters!')
        return
      }
      if (value.match(/^[a-zA-Z0-9_]+$/) === null) {
        message('Name cannot contain empty spaces!')
        return
      }
      message()
    },
    getServiceList () {
      this.$rpc.call('ubus', 'call', { object: 'service', method: 'list' }).then(response => {
        if (response.openvpn == null) return
        this.ubusData = response.openvpn.instances
      })
    }
  },
  mounted () {
    this.load()
  }
}
</script>

<style scoped>
.header {
  width: 100%;
  text-align: center;
  margin: 30px 0 10px 0;
  font-size: 16px;
}
</style>
