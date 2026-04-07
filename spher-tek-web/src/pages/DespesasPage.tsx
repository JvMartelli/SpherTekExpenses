import { useEffect, useState } from 'react';
import api from '../services/api';
import Layout from '../components/Layout';

interface Despesa {
  id: string;
  descricao: string;
  valor: number;
  status: string;
  foto_url: string;
  data_despesa: string;
  motivo_rejeicao: string | null;
  usuarios: { nome: string };
  categorias: { nome: string };
  veiculos: { placa: string; modelo: string } | null;
}

export default function DespesasPage() {
  const [despesas, setDespesas] = useState<Despesa[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [filtroStatus, setFiltroStatus] = useState('');
  const [despesaSelecionada, setDespesaSelecionada] = useState<Despesa | null>(null);
  const [motivoRejeicao, setMotivoRejeicao] = useState('');
  const [modalFoto, setModalFoto] = useState<string | null>(null);

  useEffect(() => {
    carregar();
  }, [filtroStatus]);

  async function carregar() {
    setCarregando(true);
    try {
      const url = filtroStatus ? `/despesas?status=${filtroStatus}` : '/despesas';
      const { data } = await api.get(url);
      setDespesas(data);
    } finally {
      setCarregando(false);
    }
  }

  async function aprovar(id: string) {
    await api.patch(`/despesas/${id}/aprovar`);
    carregar();
  }

  async function rejeitar(id: string) {
    if (!motivoRejeicao.trim()) {
      alert('Informe o motivo da rejeição');
      return;
    }
    await api.patch(`/despesas/${id}/rejeitar`, { motivo: motivoRejeicao });
    setDespesaSelecionada(null);
    setMotivoRejeicao('');
    carregar();
  }

  function corStatus(status: string) {
    switch (status) {
      case 'aprovada': return 'bg-green-100 text-green-800';
      case 'rejeitada': return 'bg-red-100 text-red-800';
      default: return 'bg-orange-100 text-orange-800';
    }
  }

  function labelStatus(status: string) {
    switch (status) {
      case 'aprovada': return 'Aprovada';
      case 'rejeitada': return 'Rejeitada';
      default: return 'Pendente';
    }
  }

  return (
    <Layout>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Despesas</h1>
        <select
          value={filtroStatus}
          onChange={(e) => setFiltroStatus(e.target.value)}
          className="border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="">Todas</option>
          <option value="pendente">Pendentes</option>
          <option value="aprovada">Aprovadas</option>
          <option value="rejeitada">Rejeitadas</option>
        </select>
      </div>

      {carregando ? (
        <div className="text-center py-12 text-gray-500">Carregando...</div>
      ) : despesas.length === 0 ? (
        <div className="text-center py-12 text-gray-500">Nenhuma despesa encontrada</div>
      ) : (
        <div className="bg-white rounded-xl shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="text-left px-6 py-3 text-xs font-medium text-gray-500 uppercase">Comprovante</th>
                <th className="text-left px-6 py-3 text-xs font-medium text-gray-500 uppercase">Descrição</th>
                <th className="text-left px-6 py-3 text-xs font-medium text-gray-500 uppercase">Motorista</th>
                <th className="text-left px-6 py-3 text-xs font-medium text-gray-500 uppercase">Categoria</th>
                <th className="text-left px-6 py-3 text-xs font-medium text-gray-500 uppercase">Veículo</th>
                <th className="text-left px-6 py-3 text-xs font-medium text-gray-500 uppercase">Data</th>
                <th className="text-right px-6 py-3 text-xs font-medium text-gray-500 uppercase">Valor</th>
                <th className="text-center px-6 py-3 text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="text-center px-6 py-3 text-xs font-medium text-gray-500 uppercase">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {despesas.map((d) => (
                <tr key={d.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <img
                      src={d.foto_url}
                      alt="comprovante"
                      className="w-12 h-12 object-cover rounded-lg cursor-pointer hover:opacity-80"
                      onClick={() => setModalFoto(d.foto_url)}
                    />
                  </td>
                  <td className="px-6 py-4 font-medium text-gray-800">{d.descricao}</td>
                  <td className="px-6 py-4 text-gray-600">{d.usuarios?.nome}</td>
                  <td className="px-6 py-4 text-gray-600">{d.categorias?.nome}</td>
                  <td className="px-6 py-4 text-gray-600">{d.veiculos?.placa ?? '-'}</td>
                  <td className="px-6 py-4 text-gray-600">{d.data_despesa}</td>
                  <td className="px-6 py-4 text-right font-bold text-blue-700">
                    R$ {Number(d.valor).toFixed(2)}
                  </td>
                  <td className="px-6 py-4 text-center">
                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${corStatus(d.status)}`}>
                      {labelStatus(d.status)}
                    </span>
                    {d.motivo_rejeicao && (
                      <p className="text-xs text-red-500 mt-1">{d.motivo_rejeicao}</p>
                    )}
                  </td>
                  <td className="px-6 py-4 text-center">
                    {d.status === 'pendente' && (
                      <div className="flex gap-2 justify-center">
                        <button
                          onClick={() => aprovar(d.id)}
                          className="bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded-lg text-xs font-medium"
                        >
                          Aprovar
                        </button>
                        <button
                          onClick={() => setDespesaSelecionada(d)}
                          className="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded-lg text-xs font-medium"
                        >
                          Rejeitar
                        </button>
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal rejeição */}
      {despesaSelecionada && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
            <h2 className="text-lg font-bold mb-4">Rejeitar Despesa</h2>
            <p className="text-gray-600 mb-3">Informe o motivo da rejeição:</p>
            <textarea
              value={motivoRejeicao}
              onChange={(e) => setMotivoRejeicao(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-red-500 h-24"
              placeholder="Ex: Recibo ilegível, valor incorreto..."
            />
            <div className="flex gap-3 mt-4 justify-end">
              <button
                onClick={() => { setDespesaSelecionada(null); setMotivoRejeicao(''); }}
                className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                onClick={() => rejeitar(despesaSelecionada.id)}
                className="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg font-medium"
              >
                Confirmar Rejeição
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal foto */}
      {modalFoto && (
        <div
          className="fixed inset-0 bg-black bg-opacity-80 flex items-center justify-center z-50 cursor-pointer"
          onClick={() => setModalFoto(null)}
        >
          <img src={modalFoto} alt="comprovante" className="max-w-2xl max-h-screen rounded-xl" />
        </div>
      )}
    </Layout>
  );
}
