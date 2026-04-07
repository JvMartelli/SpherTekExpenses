import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class CategoriasService {
  constructor(private supabase: SupabaseService) {}

  async listar(empresa_id: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('categorias')
      .select('*')
      .eq('empresa_id', empresa_id)
      .eq('ativo', true)
      .order('nome');

    if (error) throw new Error(error.message);
    return data;
  }

  async criar(empresa_id: string, dto: any) {
    const { data, error } = await this.supabase
      .getClient()
      .from('categorias')
      .insert({
        empresa_id,
        nome: dto.nome,
        exige_placa: dto.exige_placa ?? false,
      })
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async atualizar(id: string, empresa_id: string, dto: any) {
    const { data, error } = await this.supabase
      .getClient()
      .from('categorias')
      .update({
        nome: dto.nome,
        exige_placa: dto.exige_placa,
        ativo: dto.ativo,
      })
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async deletar(id: string, empresa_id: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('categorias')
      .update({ ativo: false })
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }
}
