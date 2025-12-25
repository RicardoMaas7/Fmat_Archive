import express from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Ruta de prueba (Health Check)
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Backend fmat_archive funcionando ' 
  });
});

// Ruta para probar la Base de Datos
app.get('/api/users', async (req, res) => {
  try {
    const users = await prisma.user.findMany();
    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al conectar con la BD' });
  }
});

// --- ESTA ES LA PARTE IMPORTANTE ---
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});