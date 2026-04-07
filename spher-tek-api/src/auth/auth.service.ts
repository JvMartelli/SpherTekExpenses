import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { SupabaseService } from '../supabase/supabase.service';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AuthService {
  constructor(
    private supabase: SupabaseService,
    private jwt: JwtService,
  ) {}

  async login(email: string, senha: string) {
    const { data: usuario, error } = await this.supabase
      .getClient()
      .from('usuarios')
      .select('*, empresas(*)')
      .eq('email', email)
      .eq('ativo', true)
      .single();

    if (error || !usuario) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const senhaValida = await bcrypt.compare(senha, usuario.senha_hash);
    if (!senhaValida) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    if (!usuario.empresas.ativo) {
      throw new UnauthorizedException('Empresa inativa');
    }

    const payload = {
      sub: usuario.id,
      email: usuario.email,
      perfil: usuario.perfil,
      empresa_id: usuario.empresa_id,
    };

    return {
      access_token: this.jwt.sign(payload),
      usuario: {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
        perfil: usuario.perfil,
        empresa_id: usuario.empresa_id,
      },
    };
  }
}
