import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsuariosService {
  constructor(private supabase: SupabaseService) {}

  async listar(empresa_id: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('usuarios')
      .select('id, nome, email, perfil, ativo, criado_em')
      .eq('empresa_id', empresa_id)
      .order('nome');

    if (error) throw new Error(error.message);
    return data;
  }

  async criar(empresa_id: string, dto: any) {
    const senha_hash = await bcrypt.hash(dto.senha, 10);

    const { data, error } = await this.supabase
      .getClient()
      .from('usuarios')
      .insert({
        empresa_id,
        nome: dto.nome,
        email: dto.email,
        senha_hash,
        perfil: dto.perfil,
      })
      .select('id, nome, email, perfil, ativo, criado_em')
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async atualizar(id: string, empresa_id: string, dto: any) {
    const atualizacao: any = {
      nome: dto.nome,
      email: dto.email,
      perfil: dto.perfil,
      ativo: dto.ativo,
    };

    if (dto.senha) {
      atualizacao.senha_hash = await bcrypt.hash(dto.senha, 10);
    }

    const { data, error } = await this.supabase
      .getClient()
      .from('usuarios')
      .update(atualizacao)
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .select('id, nome, email, perfil, ativo, criado_em')
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async deletar(id: string, empresa_id: string) {
    const { data, error } = await this.supabase
      .getClient()
      .from('usuarios')
      .update({ ativo: false })
      .eq('id', id)
      .eq('empresa_id', empresa_id)
      .select('id, nome, email, perfil, ativo')
      .single();

    if (error) throw new Error(error.message);
    return data;
  }
}