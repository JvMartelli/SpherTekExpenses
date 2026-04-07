import { createContext, useContext, useState, ReactNode } from 'react';
import api from '../services/api';

interface Usuario {
  id: string;
  nome: string;
  email: string;
  perfil: string;
  empresa_id: string;
}

interface AuthContextType {
  usuario: Usuario | null;
  login: (email: string, senha: string) => Promise<void>;
  logout: () => void;
  isAdmin: boolean;
  isFinanceiro: boolean;
}

const AuthContext = createContext<AuthContextType>({} as AuthContextType);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [usuario, setUsuario] = useState<Usuario | null>(() => {
    const saved = localStorage.getItem('usuario');
    return saved ? JSON.parse(saved) : null;
  });

  async function login(email: string, senha: string) {
    const { data } = await api.post('/auth/login', { email, senha });

    if (data.usuario.perfil === 'motorista') {
      throw new Error('Acesso negado. Use o aplicativo mobile.');
    }

    localStorage.setItem('token', data.access_token);
    localStorage.setItem('usuario', JSON.stringify(data.usuario));
    setUsuario(data.usuario);
  }

  function logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    setUsuario(null);
  }

  const isAdmin = usuario?.perfil === 'administrador';
  const isFinanceiro = usuario?.perfil === 'financeiro';

  return (
    <AuthContext.Provider value={{ usuario, login, logout, isAdmin, isFinanceiro }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}