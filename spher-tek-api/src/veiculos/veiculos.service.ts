import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class VeiculosService {
  constructor(private supabase: SupabaseService) {}

  async listar(empresa_id: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('veiculos')
      .select('*')
      .eq('empresa_id', empresa_id)
      .eq('ativo', true)
      .order('placa');

    if (error) throw new Error(error.message);
    return data;
  }

  async criar(empresa_id: string, dto: any) {
    const { data, error } = await this.supabase
      .getClient()
      .from('veiculos')
      .insert({
        empresa_id,
        placa: dto.placa,
        modelo: dto.modelo ?? null,
      })
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async atualizar(id: string, empresa_id: string, dto: any) {
    const { data, error } = await this.supabase
      .getClient()
      .from('veiculos')
      .update({
        placa: dto.placa,
        modelo: dto.modelo,
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
      .from('veiculos')
      .update({ ativo: false })
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }
}
