import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Patch,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import { DespesasService } from './despesas.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('despesas')
export class DespesasController {
  constructor(private despesasService: DespesasService) {}

  // Lista despesas da empresa (com filtro opcional de status)
  @Get()
  async listar(@Request() req, @Query('status') status?: string) {
    return this.despesasService.listar(req.user.empresa_id, status);
  }

  // Busca uma despesa pelo ID
  @Get(':id')
  async buscarPorId(@Param('id') id: string, @Request() req) {
    return this.despesasService.buscarPorId(id, req.user.empresa_id);
  }

  // Cria uma nova despesa (app mobile)
  @Post()
  async criar(@Body() body: any, @Request() req) {
    return this.despesasService.criar(
      req.user.empresa_id,
      req.user.id,
      body,
    );
  }

  // Sincroniza despesas em lote (app mobile offline)
  @Post('sincronizar')
  async sincronizar(@Body() body: { despesas: any[] }, @Request() req) {
    return this.despesasService.sincronizar(
      req.user.empresa_id,
      req.user.id,
      body.despesas,
    );
  }

  // Aprova uma despesa (financeiro)
  @Patch(':id/aprovar')
  async aprovar(@Param('id') id: string, @Request() req) {
    return this.despesasService.aprovar(id, req.user.empresa_id);
  }

  // Rejeita uma despesa (financeiro)
  @Patch(':id/rejeitar')
  async rejeitar(
    @Param('id') id: string,
    @Body() body: { motivo: string },
    @Request() req,
  ) {
    return this.despesasService.rejeitar(id, req.user.empresa_id, body.motivo);
  }
}