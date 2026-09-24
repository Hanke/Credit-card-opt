import { execSync } from 'node:child_process'
import path from 'node:path'

export default function globalSetup(): void {
  execSync('RAILS_ENV=test bin/rails db:truncate_all', {
    cwd: path.resolve(import.meta.dirname, '../../backend'),
    stdio: 'inherit',
  })
}
