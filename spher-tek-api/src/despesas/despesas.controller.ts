import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Patch,
  Delete,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import { DespesasService } from './despesas.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('despesas')
export class DespesasController {
  constructor(private despesasService: DespesasService) {}

  @Get()
  @Roles('financeiro', 'administrador', 'motorista')
  async listar(@Request() req, @Query('status') status?: string) {
    return this.despesasService.listar(req.user.empresa_id, status);
  }

  @Get(':id')
  @Roles('financeiro', 'administrador', 'motorista')
  async buscarPorId(@Param('id') id: string, @Request() req) {
    return this.despesasService.buscarPorId(id, req.user.empresa_id);
  }

  @Post()
  @Roles('motorista')
  async criar(@Body() body: any, @Request() req) {
    return this.despesasService.criar(req.user.empresa_id, req.user.id, body);
  }

  @Post('sincronizar')
  @Roles('motorista')
  async sincronizar(@Body() body: { despesas: any[] }, @Request() req) {
    return this.despesasService.sincronizar(
      req.user.empresa_id,
      req.user.id,
      body.despesas,
    );
  }

  @Patch(':id/aprovar')
  @Roles('financeiro', 'administrador')
  async aprovar(@Param('id') id: string, @Request() req) {
    return this.despesasService.aprovar(id, req.user.empresa_id);
  }

  @Patch(':id/rejeitar')
  @Roles('financeiro', 'administrador')
  async rejeitar(
    @Param('id') id: string,
    @Body() body: { motivo: string },
    @Request() req,
  ) {
    return this.despesasService.rejeitar(id, req.user.empresa_id, body.motivo);
  }

  @Delete(':id')
  @Roles('motorista', 'administrador')
  async deletar(@Param('id') id: string, @Request() req) {
    return this.despesasService.deletar(id, req.user.empresa_id);
  }
}