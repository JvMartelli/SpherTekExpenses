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

  @Get()
  async listar(@Request() req, @Query('status') status?: string) {
    return this.despesasService.listar(req.user.empresa_id, status);
  }

  @Get(':id')
  async buscarPorId(@Param('id') id: string, @Request() req) {
    return this.despesasService.buscarPorId(id, req.user.empresa_id);
  }

  @Post()
  async criar(@Body() body: any, @Request() req) {
    return this.despesasService.criar(req.user.empresa_id, req.user.id, body);
  }

  @Post('sincronizar')
  async sincronizar(@Body() body: { despesas: any[] }, @Request() req) {
    return this.despesasService.sincronizar(
      req.user.empresa_id,
      req.user.id,
      body.despesas,
    );
  }

  @Patch(':id/aprovar')
  async aprovar(@Param('id') id: string, @Request() req) {
    return this.despesasService.aprovar(id, req.user.empresa_id);
  }

  @Patch(':id/rejeitar')
  async rejeitar(
    @Param('id') id: string,
    @Body() body: { motivo: string },
    @Request() req,
  ) {
    return this.despesasService.rejeitar(id, req.user.empresa_id, body.motivo);
  }
}
