import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SupabaseModule } from './supabase/supabase.module';
import { AuthModule } from './auth/auth.module';
import { DespesasModule } from './despesas/despesas.module';
import { CategoriasModule } from './categorias/categorias.module';
import { VeiculosModule } from './veiculos/veiculos.module';
import { UsuariosModule } from './usuarios/usuarios.module';
import { UploadModule } from './upload/upload.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    SupabaseModule,
    AuthModule,
    DespesasModule,
    CategoriasModule,
    VeiculosModule,
    UsuariosModule,
    UploadModule,
  ],
})
export class AppModule {}