<template>
  <a-upload action="/upload" @change="onUpload" :beforeUpload="validate" :data="{path: `${path}cbid.openvpn.${record._name}.${convertor[certName].value}` }">
    <a-button type="primary" icon="upload" ghost>Upload file</a-button>
    <div v-if="record[convertor[certName].key] != null" class="file-name">
      <label>{{ record[convertor[certName].key].split('/')[4] }}</label>
    </div>
  </a-upload>
</template>

<script>
export default {
  props: ['configFile', 'record', 'certName'],
  data () {
    return {
      convertor: {
        'ca.cert.pem': { key: 'ca', value: 'caca.cert.pem' },
        'static.key': { key: 'secret', value: 'secretstatic.key' },
        'client.cert.pem': { key: 'cert', value: 'certclient.cert.pem' },
        'client.key.pem': { key: 'key', value: 'keyclient.key.pem' },
        'dh.pem': { key: 'dh', value: 'dhdh.pem' },
        'server.cert.pem': { key: 'cert', value: 'certserver.cert.pem' },
        'server.key.pem': { key: 'key', value: 'keyserver.key.pem' }
      },
      path: '/etc/vuci-uploads/openvpn/',
      fullPath: ''
    }
  },
  methods: {
    validate (info) {
      this.fullPath = `${this.path}cbid.openvpn.${this.record._name}.${this.convertor[this.certName].value}`
    },
    onUpload (info) {
      const file = info.file
      const status = file.status

      if (status === 'uploading' || status === 'removed') return

      info.fileList.length = 0

      if (status !== 'done') {
        this.$message.error('Upload failed!', 5)
        return
      }
      this.$uci.set(this.configFile, this.record._name, this.convertor[this.certName].key, this.fullPath)
      this.$message.success(`File '${file.name}' uploaded successfully!`, 5)
      this.$emit('uploaded')
    }
  }
}
</script>

<style scoped>
.file-name {
  margin-top: 10px
}
</style>
