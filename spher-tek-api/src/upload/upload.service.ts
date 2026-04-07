import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class UploadService {
  constructor(private supabase: SupabaseService) {}

  async uploadFoto(
    arquivo: Buffer,
    nomeArquivo: string,
    mimeType: string,
  ): Promise<string> {
    const caminho = `comprovantes/${Date.now()}_${nomeArquivo}`;

    const { error } = await this.supabase
      .getAdminClient()
      .storage
      .from('comprovantes')
      .upload(caminho, arquivo, {
        contentType: mimeType,
        upsert: false,
      });

    if (error) throw new Error(error.message);

    const { data } = this.supabase
      .getAdminClient()
      .storage
      .from('comprovantes')
      .getPublicUrl(caminho);

    return data.publicUrl;
  }
}