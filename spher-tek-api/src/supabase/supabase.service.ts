import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private client: SupabaseClient;
  private adminClient: SupabaseClient;

  constructor(private config: ConfigService) {
    this.client = createClient(
      this.config.get<string>('SUPABASE_URL') as string,
      this.config.get<string>('SUPABASE_KEY') as string,
    );

    this.adminClient = createClient(
      this.config.get<string>('SUPABASE_URL') as string,
      this.config.get<string>('SUPABASE_SERVICE_KEY') as string,
    );
  }

  getClient(): SupabaseClient {
    return this.client;
  }

  getAdminClient(): SupabaseClient {
    return this.adminClient;
  }
}