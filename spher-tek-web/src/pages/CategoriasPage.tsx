import { useEffect, useState } from 'react';
import api from '../services/api';
import Layout from '../components/Layout';

interface Categoria {
  id: string;
  nome: string;
  exige_placa: boolean;
  ativo: boolean;
}

export default function CategoriasPage() {
  const [categorias, setCategorias] = useState<Categoria[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [modalAberto, setModalAberto] = useState(false);
  const [nome, setNome] = useState('');
  const [exigePlaca, setExigePlaca] = useState(false);
  const [salvando, setSalvando] = useState(false);

  useEffect(() => {
    carregar();
  }, []);

  async function carregar() {
    setCarregando(true);
    try {
      const { data } = await api.get('/categorias');
      setCategorias(data);
    } finally {
      setCarregando(false);
    }
  }

  async function criar() {
    if (!nome.trim()) return;
    setSalvando(true);
    try {
      await api.post('/categorias', { nome, exige_placa: exigePlaca });
      setModalAberto(false);
      setNome('');
      setExigePlaca(false);
      carregar();
    } finally {
      setSalvando(false);
    }
  }

  async function deletar(id: string) {
    if (!confirm('Desativar esta categoria?')) return;
    await api.delete(`/categorias/${id}`);
    carregar();
  }

  return (
    <Layout>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Categorias</h1>
        <button
          onClick={() => setModalAberto(true)}
          className="bg-blue-700 hover:bg-blue-800 text-white px-4 py-2 rounded-lg font-medium"
        >
          + Nova Categoria
        </button>
      </div>

      {carregando ? (
        <div className="text-center py-12 text-gray-500">Carregando...</div>
      ) : (
        <div className="bg-white rounded-xl shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="text-left px-6 py-3 text-xs font-medium text-gray-500 uppercase">Nome</th>
                <th className="text-center px-6 py-3 text-xs font-medium text-gray-500 uppercase">Exige Placa</th>
                <th className="text-center px-6 py-3 text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="text-center px-6 py-3 text-xs font-medium text-gray-500 uppercase">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {categorias.map((c) => (
                <tr key={c.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 font-medium text-gray-800">{c.nome}</td>
                  <td className="px-6 py-4 text-center">
                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${c.exige_placa ? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-600'}`}>
                      {c.exige_placa ? 'Sim' : 'Não'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${c.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                      {c.ativo ? 'Ativo' : 'Inativo'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <button
                      onClick={() => deletar(c.id)}
                      className="text-red-500 hover:text-red-700 text-sm font-medium"
                    >
                      Desativar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {modalAberto && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
            <h2 className="text-lg font-bold mb-4">Nova Categoria</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Nome</label>
                <input
                  type="text"
                  value={nome}
                  onChange={(e) => setNome(e.target.value)}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Ex: Combustível"
                />
              </div>
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  id="exigePlaca"
                  checked={exigePlaca}
                  onChange={(e) => setExigePlaca(e.target.checked)}
                  className="w-4 h-4"
                />
                <label htmlFor="exigePlaca" className="text-sm font-medium text-gray-700">
                  Exige seleção de veículo/placa
                </label>
              </div>
            </div>
            <div className="flex gap-3 mt-6 justify-end">
              <button
                onClick={() => { setModalAberto(false); setNome(''); setExigePlaca(false); }}
                className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                onClick={criar}
                disabled={salvando}
                className="px-4 py-2 bg-blue-700 hover:bg-blue-800 text-white rounded-lg font-medium disabled:opacity-50"
              >
                {salvando ? 'Salvando...' : 'Salvar'}
              </button>
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
}
