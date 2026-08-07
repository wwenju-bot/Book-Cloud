const fs = require('fs')
const path = require('path')

const utf8 = 'utf8'

function write(file, text) {
  fs.writeFileSync(file, text, { encoding: utf8 })
  const head = fs.readFileSync(file).slice(0, 24)
  console.log('WROTE', file, 'head=', Array.from(head).join(','))
}

const readme = [
  '# \u521b\u4f5c\u5de5\u4f5c\u53f0\uff08book-workstation\uff09',
  '',
  '\u9762\u5411\u5199\u624b\u7684\u72ec\u7acb\u524d\u7aef\uff0c\u4e0e `book-ui`\uff08\u7ba1\u7406\u7aef Vue2\uff09\u5206\u79bb\u3002\u6280\u672f\u6808\uff1aVue3 + Vite + Pinia + Vue Router + Element Plus\u3002',
  '',
  '## \u542f\u52a8',
  '',
  '\u524d\u7f6e\uff1a\u7f51\u5173 `8080`\u3001`book-auth`\u3001`book-novel`\u3001`book-ai`\u3001Nacos\u3001Redis\u3001MySQL \u5df2\u542f\u52a8\u3002',
  '',
  '```bash',
  'cd Book-Cloud/book-workstation',
  'npm install',
  'npm run dev',
  '```',
  '',
  '\u6d4f\u89c8\u5668\u6253\u5f00\uff1ahttp://localhost:5173',
  '',
  '\u9ed8\u8ba4\u53ef\u7528\u7ba1\u7406\u7aef\u8d26\u53f7\u767b\u5f55\uff08\u5982 `admin` / `admin123`\uff09\uff0c\u9700\u586b\u5199\u7f51\u5173\u6570\u5b66\u9a8c\u8bc1\u7801\u3002',
  '',
  '## \u80fd\u529b\uff08\u9636\u6bb51\u5bf9\u63a5\uff09',
  '',
  '- \u9879\u76ee CRUD',
  '- \u53c2\u8003\u8d44\u6599\u4e0a\u4f20',
  '- \u67b6\u6784\u89e3\u6790 / \u7f16\u8f91 / \u5ba1\u6838',
  '- \u7ae0\u8282\u751f\u6210\u4e0e\u7248\u672c\u67e5\u770b',
  '- \u77e5\u8bc6\u5e93 zip \u5bfc\u51fa',
  '',
  '\u5de6\u4fa7\u83dc\u5355\u4e3a\u524d\u7aef\u5199\u6b7b\uff0c\u4e0d\u8d70\u540e\u53f0\u52a8\u6001\u6743\u9650\u3002',
  '',
  '## \u4e0e book-ui \u5165\u53e3',
  '',
  '\u83dc\u5355\u300c\u5c0f\u8bf4\u81ea\u52a8\u5316\u521b\u4f5c\u5e73\u53f0\u300d\u5916\u94fe\u6307\u5411\u672c\u5de5\u4f5c\u53f0\uff08\u5f00\u53d1\u73af\u5883 `http://localhost:5173`\uff09\u3002',
  '\u8865\u4e01\u811a\u672c\uff1a`Book-Cloud/sql/book_workstation_menu_20260806.sql`\u3002',
  ''
].join('\n')

const sql = [
  '-- \u5c06\u300c\u5c0f\u8bf4\u81ea\u52a8\u5316\u521b\u4f5c\u5e73\u53f0\u5b98\u7f51\u300d\u5916\u94fe\u6539\u4e3a\u521b\u4f5c\u5de5\u4f5c\u53f0\uff08\u5f00\u53d1\u73af\u5883\uff09',
  '-- \u6267\u884c\u540e\u5237\u65b0 book-ui \u9875\u9762\uff0c\u70b9\u51fb\u8be5\u83dc\u5355\u5e94\u6253\u5f00 http://localhost:5173',
  '-- \u5ba3\u4f20\u843d\u5730\u9875\u4ecd\u4fdd\u7559\u5728 book-ui/public/novel-platform/index.html\uff0c\u53ef\u6309\u9700\u53e6\u5efa\u83dc\u5355\u6307\u5411',
  '',
  'UPDATE sys_menu',
  "SET menu_name = '\u4e00\u7ad9\u5f0f\u5c0f\u8bf4\u521b\u4f5c\u5e73\u53f0',",
  "    path = 'http://localhost:5173',",
  "    remark = '\u521b\u4f5c\u5de5\u4f5c\u53f0\uff08book-workstation\uff0cVue3\uff09\u3002\u5f00\u53d1\u9ed8\u8ba4\u7aef\u53e3 5173\uff1b\u751f\u4ea7\u8bf7\u6539\u4e3a\u5b9e\u9645\u90e8\u7f72\u57df\u540d\u3002'",
  'WHERE menu_id = 4;',
  ''
].join('\n')

const inspiration = [
  '# \u77ed\u7bc7\u7075\u611f\u793a\u4f8b\uff08\u4e0a\u4f20\u7528\uff09',
  '',
  '\u6211\u662f\u4e00\u540d\u7a7f\u8d8a\u8005\uff0c\u843d\u5728\u4e00\u4e2a\u300c\u7075\u6c14\u590d\u82cf\u300d\u521a\u5f00\u59cb\u7684\u73b0\u4ee3\u90fd\u5e02\u3002',
  '',
  '\u6838\u5fc3\u8bbe\u5b9a\uff1a',
  '- \u57ce\u5e02\u5730\u4e0b\u5c01\u5370\u677e\u52a8\uff0c\u666e\u901a\u4eba\u5f00\u59cb\u89c9\u9192\u5f02\u80fd\uff0c\u653f\u5e9c\u6210\u7acb\u300c\u5f02\u80fd\u7ba1\u7406\u5c40\u300d\u7ba1\u63a7\u3002',
  '- \u4e3b\u89d2\u6797\u6f88\uff0c\u666e\u901a\u5927\u5b66\u751f\uff0c\u89c9\u9192\u300c\u56de\u6eaf\u5341\u79d2\u300d\u80fd\u529b\uff0c\u4ee3\u4ef7\u662f\u6bcf\u6b21\u4f7f\u7528\u540e\u4f1a\u77ed\u6682\u5931\u5fc6\u3002',
  '- \u5973\u4e3b\u82cf\u665a\uff0c\u7ba1\u7406\u5c40\u65b0\u4eba\u8c03\u67e5\u5458\uff0c\u8868\u9762\u51b7\u6de1\uff0c\u5b9e\u9645\u5728\u8ffd\u67e5\u5931\u8e2a\u7684\u54e5\u54e5\u3002',
  '- \u53cd\u6d3e\u300c\u96fe\u884c\u4f1a\u300d\u60f3\u5f7b\u5e95\u6495\u5f00\u5c01\u5370\uff0c\u653e\u51fa\u4e0a\u53e4\u7075\u517d\u3002',
  '',
  '\u4e3b\u7ebf\uff1a\u6797\u6f88\u8bef\u89e6\u5c01\u5370\u788e\u7247 \u2192 \u88ab\u82cf\u665a\u76ef\u4e0a \u2192 \u4e24\u4eba\u88ab\u8feb\u5408\u4f5c\u8c03\u67e5\u8fde\u73af\u5f02\u80fd\u6848\u4ef6 \u2192 \u53d1\u73b0\u96fe\u884c\u4f1a\u771f\u6b63\u76ee\u6807\u662f\u4e3b\u89d2\u4f53\u5185\u7684\u300c\u94a5\u5319\u300d\u3002',
  '',
  '\u8bf7\u6309\u6b64\u7d20\u6750\u751f\u6210\u7ed3\u6784\u5316\u5c0f\u8bf4\u67b6\u6784\uff1a\u4e16\u754c\u89c2\u3001\u4eba\u7269\u5c0f\u4f20\u3001\u5267\u60c5\u7ebf\u3001\u4f0f\u7b14\u6e05\u5355\u3002',
  ''
].join('\n')

const root = 'e:/work/book/book/Book-Cloud'
write(path.join(root, 'book-workstation/README.md'), readme)
write(path.join(root, 'sql/book_workstation_menu_20260806.sql'), sql)

const postmanDir = path.join(root, 'docs/postman')
const oldTxt = fs.readdirSync(postmanDir).find((n) => n.endsWith('.txt'))
const oldJson = fs.readdirSync(postmanDir).find((n) => n.endsWith('.json'))
if (oldTxt) {
  const target = path.join(postmanDir, '\u7075\u611f\u7d20\u6750-\u793a\u4f8b.txt')
  write(target, inspiration)
  if (path.join(postmanDir, oldTxt) !== target) {
    try { fs.unlinkSync(path.join(postmanDir, oldTxt)) } catch (_) {}
  }
}
if (oldJson) {
  // keep content; rename to ascii-safe name if needed
  const src = path.join(postmanDir, oldJson)
  const dest = path.join(postmanDir, 'Book-Novel-phase1-e2e.postman_collection.json')
  if (src !== dest) {
    fs.copyFileSync(src, dest)
    try { fs.unlinkSync(src) } catch (_) {}
    console.log('RENAMED postman collection to ascii name')
  }
}

console.log('done')
