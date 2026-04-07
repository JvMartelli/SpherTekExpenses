import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { VeiculosService } from './veiculos.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('veiculos')
export class VeiculosController {
  constructor(private veiculosService: VeiculosService) {}

  @Get()
  async listar(@Request() req) {
    return this.veiculosService.listar(req.user.empresa_id);
  }

  @Post()
  @Roles('administrador')
  async criar(@Body() body: any, @Request() req) {
    return this.veiculosService.criar(req.user.empresa_id, body);
  }

  @Patch(':id')
  @Roles('administrador')
  async atualizar(@Param('id') id: string, @Body() body: any, @Request() req) {
    return this.veiculosService.atualizar(id, req.user.empresa_id, body);
  }

  @Delete(':id')
  @Roles('administrador')
  async deletar(@Param('id') id: string, @Request() req) {
    return this.veiculosService.deletar(id, req.user.empresa_id);
  }
}