#!/usr/bin/env node

/**
 * Script de validación de entorno para Fmat_Archive
 * Verifica que todos los prerequisitos estén instalados y configurados
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import { existsSync } from 'fs';
import { join } from 'path';

const execAsync = promisify(exec);

const checks = [];
let hasErrors = false;

function logSuccess(message) {
  console.log(`[OK] ${message}`);
}

function logError(message) {
  console.log(`[ERROR] ${message}`);
  hasErrors = true;
}

function logWarning(message) {
  console.log(`[WARNING] ${message}`);
}

async function checkCommand(command, minVersion, name) {
  try {
    const { stdout } = await execAsync(command);
    const version = stdout.trim();
    logSuccess(`${name}: ${version}`);
    return true;
  } catch (error) {
    logError(`${name} no está instalado o no se encuentra en PATH`);
    return false;
  }
}

async function checkFile(filePath, name) {
  if (existsSync(filePath)) {
    logSuccess(`${name} existe`);
    return true;
  } else {
    logError(`${name} no existe en: ${filePath}`);
    return false;
  }
}

async function checkDocker() {
  try {
    await execAsync('docker ps');
    logSuccess('Docker está corriendo');
    return true;
  } catch (error) {
    logError('Docker no está corriendo. Abre Docker Desktop e intenta nuevamente.');
    return false;
  }
}

async function main() {
  console.log('===============================================');
  console.log('Fmat_Archive - Environment Validation Script');
  console.log('===============================================\n');

  // 1. Verificar Node.js
  console.log('Prerequisitos:');
  await checkCommand('node -v', '20', 'Node.js');
  await checkCommand('npm -v', null, 'npm');
  await checkCommand('git --version', null, 'Git');
  await checkCommand('docker --version', null, 'Docker');
  await checkCommand('docker-compose --version', null, 'Docker Compose');
  
  // 2. Verificar Docker corriendo
  console.log('\nDocker Status:');
  await checkDocker();

  // 3. Verificar archivos de configuración
  console.log('\nConfiguration Files:');
  await checkFile('.env', 'Root .env file');
  await checkFile('backend/.env', 'Backend .env file');

  // 4. Verificar dependencias instaladas
  console.log('\nDependencies:');
  await checkFile('backend/node_modules', 'Backend dependencies');
  await checkFile('frontend/node_modules', 'Frontend dependencies');

  // 5. Verificar contenedores Docker
  console.log('\nDocker Containers:');
  try {
    const { stdout } = await execAsync('docker ps --format "{{.Names}}"');
    const containers = stdout.trim().split('\n').filter(Boolean);
    
    if (containers.includes('fmat_archive_db')) {
      logSuccess('Container fmat_archive_db is running');
    } else {
      logWarning('Container fmat_archive_db is not running. Execute: docker-compose up -d');
    }
    
    if (containers.includes('fmat_archive_adminer')) {
      logSuccess('Container fmat_archive_adminer is running');
    } else {
      logWarning('Container fmat_archive_adminer is not running. Execute: docker-compose up -d');
    }
  } catch (error) {
    logWarning('Could not verify Docker containers');
  }

  // 6. Resumen final
  console.log('\n' + '='.repeat(50));
  if (hasErrors) {
    console.log('FAILED: Environment has errors that need to be fixed.');
    console.log('Check ONBOARDING.md for detailed instructions.');
    process.exit(1);
  } else {
    console.log('SUCCESS: Environment is correctly configured!\n');
    console.log('Next steps:');
    console.log('   1. docker-compose up -d (if not already running)');
    console.log('   2. cd backend && npx prisma db push');
    console.log('   3. cd backend && npm run dev');
    console.log('   4. cd frontend && npm start\n');
    console.log('URLs:');
    console.log('   Frontend: http://localhost:4200');
    console.log('   Adminer:  http://localhost:8080');
  }
}

main().catch(console.error);
