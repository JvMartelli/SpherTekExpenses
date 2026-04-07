import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import LoginPage from './pages/LoginPage';
import DespesasPage from './pages/DespesasPage';
import CategoriasPage from './pages/CategoriasPage';
import VeiculosPage from './pages/VeiculosPage';
import UsuariosPage from './pages/UsuariosPage';

function RotaProtegida({ children }: { children: React.ReactNode }) {
  const { usuario } = useAuth();
  if (!usuario) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/despesas" element={<RotaProtegida><DespesasPage /></RotaProtegida>} />
          <Route path="/categorias" element={<RotaProtegida><CategoriasPage /></RotaProtegida>} />
          <Route path="/veiculos" element={<RotaProtegida><VeiculosPage /></RotaProtegida>} />
          <Route path="/usuarios" element={<RotaProtegida><UsuariosPage /></RotaProtegida>} />
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
