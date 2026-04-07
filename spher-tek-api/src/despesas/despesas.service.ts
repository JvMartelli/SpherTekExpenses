import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class DespesasService {
  constructor(private supabase: SupabaseService) {}

  async listar(empresa_id: string, status?: string) {
    let query = this.supabase
      .getClient()
      .from('despesas')
      .select(`
        *,
        usuarios(nome, email),
        categorias(nome, exige_placa),
        veiculos(placa, modelo)
      `)
      .eq('empresa_id', empresa_id)
      .order('criado_em', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query;
    if (error) throw new Error(error.message);
    return data;
  }

  async buscarPorId(id: string, empresa_id: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('despesas')
      .select(`
        *,
        usuarios(nome, email),
        categorias(nome, exige_placa),
        veiculos(placa, modelo)
      `)
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async criar(empresa_id: string, usuario_id: string, dto: any) {
    const { data, error } = await this.supabase
      .getClient()
      .from('despesas')
      .insert({
        empresa_id,
        usuario_id,
        categoria_id: dto.categoria_id,
        veiculo_id: dto.veiculo_id ?? null,
        descricao: dto.descricao,
        valor: dto.valor,
        foto_url: dto.foto_url,
        status: 'pendente',
        data_despesa: dto.data_despesa,
        sincronizado_em: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async aprovar(id: string, empresa_id: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('despesas')
      .update({ status: 'aprovada', motivo_rejeicao: null })
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async rejeitar(id: string, empresa_id: string, motivo: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('despesas')
      .update({ status: 'rejeitada', motivo_rejeicao: motivo })
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async sincronizar(empresa_id: string, usuario_id: string, despesas: any[]) {
    const resultados: any[] = [];

    for (const despesa of despesas) {
      const resultado = await this.criar(empresa_id, usuario_id, despesa);
      resultados.push(resultado);
    }

    return resultados;
  }
}
