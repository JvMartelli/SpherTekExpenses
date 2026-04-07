import { ReactNode } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

interface LayoutProps {
  children: ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const { usuario, logout, isAdmin } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  function handleLogout() {
    logout();
    navigate('/login');
  }

  const links = [
    { path: '/despesas', label: '📋 Despesas', visivel: true },
    { path: '/categorias', label: '🏷️ Categorias', visivel: isAdmin },
    { path: '/veiculos', label: '🚗 Veículos', visivel: isAdmin },
    { path: '/usuarios', label: '👥 Usuários', visivel: isAdmin },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-blue-700 text-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-xl">💰</span>
            <span className="font-bold text-lg">Spher Tek Expenses</span>
          </div>
          <div className="flex items-center gap-6">
            {links.filter(l => l.visivel).map((link) => (
              <Link
                key={link.path}
                to={link.path}
                className={`text-sm font-medium hover:text-blue-200 transition-colors ${
                  location.pathname === link.path
                    ? 'text-white border-b-2 border-white'
                    : 'text-blue-200'
                }`}
              >
                {link.label}
              </Link>
            ))}
            <div className="flex items-center gap-3 ml-4">
              <div className="text-right">
                <p className="text-sm text-white">{usuario?.nome}</p>
                <p className="text-xs text-blue-200">{usuario?.perfil === 'administrador' ? 'Administrador' : 'Financeiro'}</p>
              </div>
              <button
                onClick={handleLogout}
                className="bg-blue-800 hover:bg-blue-900 px-3 py-1 rounded-lg text-sm"
              >
                Sair
              </button>
            </div>
          </div>
        </div>
      </nav>
      <main className="max-w-7xl mx-auto px-4 py-6">
        {children}
      </main>
    </div>
  );
}